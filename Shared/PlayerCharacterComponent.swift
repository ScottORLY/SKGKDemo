import GameplayKit

class PlayerCharacterComponent: GKComponent {
    
    var stateMachine: GKStateMachine?
    
    lazy var node: SKNode? = {
        return self.entity?.component(ofType: GKSKNodeComponent.self)?.node
    }()
    
    func moveTowards(dx: CGFloat) {
        if (node?.physicsBody?.velocity.dy)! < CGFloat(0.5) {
            stateMachine?.enter(WalkingState.self)
        }
        node?.physicsBody?.velocity.dx = dx
    }
    
    func jump() {
        stateMachine?.enter(JumpingState.self)
        let vector = CGVector(dx: (node?.physicsBody?.velocity.dx)!, dy: 75.0)
        node?.physicsBody?.applyImpulse(vector, at: (node?.position)!)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if stateMachine == nil {
            stateMachine = GKStateMachine(states:
                [
                    WalkingState(with: node!),
                    JumpingState(with: node!),
                    StandingState(with: node!)
                ]
            )
            stateMachine?.enter(StandingState.self)
        }

    }
}

class CharacterState: GKState {
    weak var node: SKNode?
    
    init(with node: SKNode) {
        self.node = node
    }
}

class WalkingState: CharacterState {
    
    override func didEnter(from previousState: GKState?) {
        let action = SKAction(named: "PlayerWalkAction")
        node?.run(action!, withKey: "walking")
    }
    override func willExit(to nextState: GKState) {
        node?.removeAction(forKey: "walking")
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is StandingState.Type || stateClass is JumpingState.Type
    }
}

class JumpingState: CharacterState {
    
    override func didEnter(from previousState: GKState?) {
        let action = SKAction(named: "PlayerJumpAction")
        node?.run(action!, withKey: "jumping")
    }
    override func willExit(to nextState: GKState) {
        node?.removeAction(forKey: "jumping")
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is WalkingState.Type || stateClass is StandingState.Type
    }
}

class StandingState: CharacterState {
    
    override func didEnter(from previousState: GKState?) {
        if previousState is JumpingState {
            node?.removeAction(forKey: "jumping")
            print("remove jump")
        }
        if previousState is WalkingState {
            print("remove walk")
            node?.removeAction(forKey: "walking")
        }
    }
    override func willExit(to nextState: GKState) {
        
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is WalkingState.Type || stateClass is JumpingState.Type
    }
}
