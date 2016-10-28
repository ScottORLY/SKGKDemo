import GameplayKit
import SpriteKit

class GameScene: SKScene {
    
    lazy var playerCharacterNode: SKNode? = {
        return self.childNode(withName: "//PlayerCharacter")
    }()
    
    lazy var playerCharacherComponent: PlayerCharacterComponent? = {
        return self.playerCharacterNode?.entity?.component(ofType: PlayerCharacterComponent.self)
    }()
    
    lazy var groundTileMapNode: SKTileMapNode? = {
        return self.childNode(withName: "//GroundTileMapNode") as? SKTileMapNode
    }()
    
    lazy var waterTileMapNode: SKTileMapNode? = {
        return self.childNode(withName: "//WaterTileMapNode") as? SKTileMapNode
    }()

    lazy var elevatedTileMapNode: SKTileMapNode? = {
        return self.childNode(withName: "//ElevateTileMapNode") as? SKTileMapNode
    }()
    
    static var gkScene: GKScene?
    
    class func newGameScene() -> SKScene {
        
        guard let gkscene = GKScene(fileNamed: "GameScene") else {
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
        return scene
    }
    
    override func didMove(to view: SKView) {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: (self.waterTileMapNode?.frame)!)
    }
    
    override func update(_ currentTime: TimeInterval) {
       camera?.position = (playerCharacterNode?.position)!
    }
    
}

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

#if os(OSX)

extension GameScene {

    override func mouseDown(with event: NSEvent) {
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        
    }
    
    override func mouseUp(with event: NSEvent) {

    }

}
#endif

