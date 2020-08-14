import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    static var gkScene: GKScene?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override class var supportsSecureCoding: Bool {
        true
    }

    class func newGameScene() -> SKScene {
        
        guard let gkscene = GKScene(fileNamed: "NewNew") else {
            abort()
        }
        
        guard let scene = gkscene.rootNode as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        for entity in gkscene.entities {
            entity.addComponent(entity.component(ofType: GKSKNodeComponent.self)!)
        }
        
        gkScene = gkscene
        scene.scaleMode = .aspectFill
        scene.physicsWorld.contactDelegate = scene
        return scene
    }
    
    let playerCategory = 0x1 << 0
    let enemyCategory = 0x1 << 1
    let blockCategory = 0x1 << 2
    let powerupCategory = 0x1 << 3
    
    lazy var playerCharacherComponent: PlayerCharacterComponent? = {
        return self.playerCharacterNode?.entity?.component(ofType: PlayerCharacterComponent.self)
    }()
    
    lazy var tileMap: SKTileMapNode? = {
        return self.childNode(withName: "//Obstacles") as? SKTileMapNode
    }()
    
    var lastUpdate: TimeInterval = 0
    
    lazy var playerCharacterNode: SKNode? = {
        return self.childNode(withName: "//PlayerCharacter")
    }()
    
    let agentSystem = GKComponentSystem(componentClass: GKAgent2D.self)
    
    var playerState = GKStateMachine(states:[
        PowerupState(),
        VulnerableState()
        ])
    
    lazy var powerupNode: SKNode? = {
        return self.childNode(withName: "//powerup")
    }()
    
    override func update(_ currentTime: TimeInterval) {
  
        if lastUpdate == 0 {
            lastUpdate = currentTime
        }
        let delta = currentTime - lastUpdate
        lastUpdate = currentTime
        
        for entity in (GameScene.gkScene?.entities)! {
            entity.update(deltaTime: delta)
        }
        agentSystem.update(deltaTime: delta)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        powerupNode?.removeFromParent()
        playerState.enter(PowerupState.self)
    }
    
    func setUpTileMapPhysics() {
        var physicsBodies = [SKPhysicsBody]()
        for col in 0..<(tileMap?.numberOfColumns)! {
            for row in 0..<(tileMap?.numberOfRows)! {
                let tileDef = tileMap?.tileDefinition(atColumn: col, row: row)
                let isEdgeTile = tileDef?.userData?["edgeTile"] as? Bool
                let isHalfTile = tileDef?.userData?["halfTile"] as? Bool
                if isEdgeTile ?? false {
                    var tileSize = tileDef?.size
                    var center = tileMap?.centerOfTile(atColumn: col, row: row)
                    if isHalfTile ?? false {
                        let size = (tileSize?.height)! / 2
                        tileSize?.height = size
                    }
                    else {
                        center?.y -= 32.0
                    }
                    center?.x -= 32.0
                    let rect = CGRect(origin: center!, size: tileSize!)
                    let physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
                    physicsBody.categoryBitMask = UInt32(blockCategory)
                    physicsBody.collisionBitMask = UInt32(blockCategory | enemyCategory | playerCategory)
                    physicsBody.contactTestBitMask = UInt32(blockCategory)
                    physicsBodies.append(physicsBody)
                }
            }
        }
        let tileMapPhysicsBody = SKPhysicsBody(bodies: physicsBodies)
        tileMapPhysicsBody.isDynamic = false
        tileMapPhysicsBody.categoryBitMask = UInt32(blockCategory)
        tileMapPhysicsBody.collisionBitMask = UInt32(blockCategory | enemyCategory | playerCategory)
        tileMapPhysicsBody.contactTestBitMask = UInt32(blockCategory)
        tileMap?.physicsBody = tileMapPhysicsBody
    }

   
    override func didMove(to view: SKView) {
        setUpTileMapPhysics()
        
        playerCharacterNode?.physicsBody?.categoryBitMask = UInt32(playerCategory)
        playerCharacterNode?.physicsBody?.collisionBitMask = UInt32(playerCategory | enemyCategory | blockCategory)
        playerCharacterNode?.physicsBody?.contactTestBitMask = UInt32(playerCategory | powerupCategory)
        
        powerupNode?.physicsBody?.categoryBitMask = UInt32(powerupCategory)
        powerupNode?.physicsBody?.collisionBitMask =  UInt32(powerupCategory | playerCategory)
        powerupNode?.physicsBody?.contactTestBitMask = UInt32(powerupCategory | playerCategory)
        
        agentSystem.addComponent((playerCharacherComponent?.playerAgent)!)
        
        let seekGoal = GKGoal(toSeekAgent: (playerCharacherComponent?.playerAgent)!)
        let fleeGoal = GKGoal(toFleeAgent: (playerCharacherComponent?.playerAgent)!)
        
        enumerateChildNodes(withName: "//enemy*") { node, stop in
            
            let enemyComponent = node.entity?.component(ofType: EnemyAgent.self)
            let agent = enemyComponent?.setUpAgent(with: [seekGoal, fleeGoal])
            self.agentSystem.addComponent(agent!)
            
            enemyComponent?.setupStateMachine(with: agent!, seekGoal: seekGoal, fleeGoal: fleeGoal)
            enemyComponent?.playerState = self.playerState
            
            node.physicsBody?.categoryBitMask = UInt32(self.enemyCategory)
            node.physicsBody?.collisionBitMask = UInt32(self.playerCategory | self.enemyCategory | self.blockCategory)
            
        }
        playerState.enter(VulnerableState.self)
    }
}

#if os(OSX)
    
    extension GameScene {
        override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
            let playerLocation = playerCharacterNode?.position
            let location = event.location(in: self.scene!)
            let dx = (location.x) - (playerLocation?.x)!
            let dy = (location.y) - (playerLocation?.y)!
            playerCharacherComponent?.moveTowards(dx: dx, dy: dy)
        }
        
        override func mouseDragged(with event: NSEvent) {
            super.mouseDragged(with: event)
            let playerLocation = playerCharacterNode?.position
            let location = event.location(in: self.scene!)
            let dx = (location.x) - (playerLocation?.x)!
            let dy = (location.y) - (playerLocation?.y)!
            playerCharacherComponent?.moveTowards(dx: dx, dy: dy)
            
        }
    }
    
#endif

#if os(iOS) || os(tvOS)
    
    extension GameScene {
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesMoved(touches, with: event)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesCancelled(touches, with: event)
        }
    }
    
#endif
