import SpriteKit
import GameplayKit

class SideScrollingScene: SKScene {
    
    lazy var playerCharacterNode: SKNode? = {
        return self.childNode(withName: "//PlayerCharacter")
    }()
    
    lazy var playerCharacherComponent: PlayerCharacterComponent? = {
        return self.playerCharacterNode?.entity?.component(ofType: PlayerCharacterComponent.self)
    }()
    
    lazy var tileMap: SKTileMapNode? = {
        return self.childNode(withName:"//TileMapNode") as? SKTileMapNode
    }()
    
    static var gkScene: GKScene?
    
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
        return scene
    }
    
    override func didMove(to view: SKView) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        for entity in (SideScrollingScene.gkScene?.entities)! {
            entity.update(deltaTime: currentTime)
        }
    }
    
    func setUpTileMapPhysics() {
    
        var physicsBodies = [SKPhysicsBody]()
        for col in 0..<(tileMap?.numberOfColumns)! {
            for row in 0..<(tileMap?.numberOfRows)! {
                let tileDef = tileMap?.tileDefinition(atColumn: col, row: row)
                let isEdgeTile = tileDef?.userData?["edgeTile"] as? Bool
                if isEdgeTile ?? false {
                    var center = tileMap?.centerOfTile(atColumn: col, row: row)
                    center?.y -= 32.0
                    center?.x -= 32.0
                    let rect = CGRect(origin: center!, size: (tileDef?.size)!)
                    let physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
                    physicsBodies.append(physicsBody)
                }
            }
        }
        let tileMapPhysicsBody = SKPhysicsBody(bodies: physicsBodies)
        tileMapPhysicsBody.isDynamic = false
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
        
        override func mouseDown(with event: NSEvent) {
            
        }
        
        override func mouseDragged(with event: NSEvent) {
            
        }
        
        override func mouseUp(with event: NSEvent) {
            
        }
        
    }
#endif

