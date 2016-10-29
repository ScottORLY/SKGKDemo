import GameplayKit
import SpriteKit

class PlayerCharacterComponent: GKComponent {
    
    var stateMachine: GKStateMachine?
    
    func moveTowards(dx: CGFloat) {
        if (node?.physicsBody?.velocity.dy)! < CGFloat(0.5) {
            stateMachine?.enter(WalkingState.self)
        }
        if (dx == CGFloat(0.0) && (node?.physicsBody?.velocity.dy)! < CGFloat(0.5))  {
            self.stateMachine?.enter(StandingState.self)
        }
        node?.physicsBody?.velocity.dx = dx
    }
    
    func jump() {
        stateMachine?.enter(JumpingState.self)
        let vector = CGVector(dx: (node?.physicsBody?.velocity.dx)!, dy: 200.0)
        node?.physicsBody?.applyImpulse(vector, at: (node?.position)!)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if stateMachine == nil {
            stateMachine = GKStateMachine(states:
                [
                    WalkingState(with: node!, name: "PlayerWalkAction"),
                    JumpingState(with: node!, name: "PlayerJumpAction"),
                    StandingState(with: node!, name: "alienGreen_stand_right"),
                    HitState(with: node!, name: "alienGreen_hit")
                ]
            )
            stateMachine?.enter(StandingState.self)
        }
        
        let dx = node?.physicsBody?.velocity.dx
        let dy = node?.physicsBody?.velocity.dy
        if (dx! < CGFloat(0.5) && dx! > CGFloat(-0.5)) &&
            (dy! < CGFloat(0.5) && dy! > CGFloat (-0.5)) {
            stateMachine?.enter(StandingState.self)
        }
    }
}
