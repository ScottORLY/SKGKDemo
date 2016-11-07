import SpriteKit
import GameplayKit

class SideScrollingScene: SKScene, SKPhysicsContactDelegate {
    
    let playerCategory = 0x1 << 0
    let enemyCategory = 0x1 << 1
    let blockCategory = 0x1 << 2
    
    lazy var playerCharacterNode: SKNode? = {
        return self.childNode(withName: "//PlayerCharacter")
    }()
    
    lazy var slimeOneNode: SKNode? = {
        return self.childNode(withName: "//Slime1")
    }()
    
    lazy var playerCharacherComponent: PlayerCharacterComponent? = {
        return self.playerCharacterNode?.entity?.component(ofType: PlayerCharacterComponent.self)
    }()
    
    lazy var tileMap: SKTileMapNode? = {
        return self.childNode(withName:"//TileMapNode") as? SKTileMapNode
    }()
    
    static var gkScene: GKScene?
    
    var lastUpdate: TimeInterval = 0
    
    let agentSystem = GKComponentSystem(componentClass: GKAgent2D.self)
    
    class func newGameScene() -> SKScene {
        
        guard let gkscene = GKScene(fileNamed: "SideScrollingScene") else {
            abort()
        }
        
        guard let scene = gkscene.rootNode as? SideScrollingScene else {
            print("Failed to load SideScrollingScene.sks")
            abort()
        }
        
        for entity in gkscene.entities {
            entity.addComponent(entity.component(ofType: GKSKNodeComponent.self)!)
        }
        
        gkScene = gkscene
        scene.scaleMode = .aspectFill
        scene.setUpTileMapPhysics()
        scene.physicsWorld.contactDelegate = scene
        return scene
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        print(contact.contactNormal.dy)
        
        if contact.contactNormal.dx > CGFloat(0.8) || contact.contactNormal.dx < CGFloat(-0.8) {
            
        } else if contact.contactNormal.dy < CGFloat(-0.8) {
            slimeOneNode?.entity?.component(ofType: EnemyAgent.self)?.hitMe()
        }
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        
        }
        else {
            
        }
    }
    
    override func didMove(to view: SKView) {
        
        let graph = SideScrollingScene.gkScene?.graphs["SlimeGraph"]
        let path = GKPath(graphNodes: (graph?.nodes)!, radius: 20.0)
        path.isCyclical = true
        let goal = GKGoal(toFollow: path, maxPredictionTime: 1.5, forward: true)
        let agent = GKAgent2D()
        agent.behavior = GKBehavior(weightedGoals: [goal: 1])
        let position = slimeOneNode?.position
        agent.radius = 20.0
        agent.maxSpeed = 100
        agent.maxAcceleration = 50
        agent.position = vector_float2(Float(position!.x), Float(position!.y))
        agent.delegate = slimeOneNode?.entity?.component(ofType: EnemyAgent.self)
        agentSystem.addComponent(agent)
        
        playerCharacterNode?.physicsBody?.categoryBitMask = UInt32(playerCategory)
        playerCharacterNode?.physicsBody?.collisionBitMask = UInt32(playerCategory | enemyCategory | blockCategory)
        playerCharacterNode?.physicsBody?.contactTestBitMask = UInt32(playerCategory | enemyCategory)
        
        slimeOneNode?.physicsBody?.categoryBitMask = UInt32(enemyCategory)
        slimeOneNode?.physicsBody?.collisionBitMask = UInt32(playerCategory | enemyCategory | blockCategory)
        slimeOneNode?.physicsBody?.contactTestBitMask = UInt32(enemyCategory | playerCategory)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = currentTime
        }
        let delta = currentTime - lastUpdate
        lastUpdate = currentTime
        agentSystem.update(deltaTime: delta)
        for entity in (SideScrollingScene.gkScene?.entities)! {
            entity.update(deltaTime: delta)
        }
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
                        tileSize?.height = (tileSize?.height)! / 2
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
}

#if os(iOS) || os(tvOS)
    
extension SideScrollingScene {
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            let playerLocation = playerCharacterNode?.position
            let touch = touches.first
            if touch?.tapCount == 2 {
                playerCharacherComponent?.jump()
            } else {
                let touchLocation = touch?.location(in: self.scene!)
                let dx = (touchLocation?.x)! - (playerLocation?.x)!
                playerCharacherComponent?.moveTowards(dx: dx)
            }
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesMoved(touches, with: event)
            let playerLocation = playerCharacterNode?.position
            let touch = touches.first
            let touchLocation = touch?.location(in: self.scene!)
            let dx = (touchLocation?.x)! - (playerLocation?.x)!
            playerCharacherComponent?.moveTowards(dx: dx)
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            playerCharacherComponent?.moveTowards(dx: 0)
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesCancelled(touches, with: event)

            playerCharacherComponent?.moveTowards(dx: 0)
        }
}
#endif

#if os(OSX)

extension SideScrollingScene {
    
    //123 left
    //124 right 
    //125 down
    //126 up
    //49 space
    
    override func keyDown(with event: NSEvent) {
        //super.keyDown(with: event)
        
        switch event.keyCode {
        case 123:
            playerCharacherComponent?.moveTowards(dx: CGFloat(-100.0))
        case 124:
            playerCharacherComponent?.moveTowards(dx: CGFloat(100.0))
        case 49:
            playerCharacherComponent?.jump()
        default: break
        }
    }
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        print("right click")
    }
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        print(event.buttonNumber)
        if event.clickCount > 1 {
            playerCharacherComponent?.jump()
        }
        let playerLocation = playerCharacterNode?.position
        let location = event.location(in: self.scene!)
        let dx = (location.x) - (playerLocation?.x)!
        print(dx)
        playerCharacherComponent?.moveTowards(dx: dx)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let playerLocation = playerCharacterNode?.position
        let location = event.location(in: self.scene!)
        let dx = (location.x) - (playerLocation?.x)!
        playerCharacherComponent?.moveTowards(dx: dx)

    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
    }
    
}
    
#endif

