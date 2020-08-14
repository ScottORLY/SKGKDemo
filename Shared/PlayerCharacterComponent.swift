import GameplayKit
import SpriteKit

class PlayerCharacterComponent: GKComponent, GKAgentDelegate {

    lazy var node: SKNode? = {
        entity?.component(ofType: GKSKNodeComponent.self)?.node
    }()

    var playerAgent: GKAgent2D? = GKAgent2D()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        playerAgent?.delegate = self
        let behavior = GKBehavior()
        playerAgent?.behavior = behavior
    }

    override class var supportsSecureCoding: Bool {
        true
    }
    
    func moveTowards(dx: CGFloat, dy: CGFloat) {
        let vector = CGVector(dx: dx, dy: dy)
        node?.physicsBody?.velocity = vector
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
        if let agent2d = agent as? GKAgent2D {
            agent2d.position = float2(Float((node?.position.x)!), Float((node?.position.y)!))
        }
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        if let agent2d = agent as? GKAgent2D {
            node?.position = CGPoint(x: CGFloat(agent2d.position.x), y: CGFloat(agent2d.position.y))
        }
    }
}
