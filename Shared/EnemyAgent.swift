import GameplayKit

class EnemyAgent: GKComponent, GKAgentDelegate {
    
    var stateMachine: GKStateMachine?
    var playerState: GKStateMachine?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if playerState?.currentState is PowerupState {
            stateMachine?.enter(FleeingState.self)
        } else {
            stateMachine?.enter(SeekingState.self)
        }
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
    
    func setUpAgent(with goals: [GKGoal]) -> GKAgent2D {
        let agent = GKAgent2D()
        let behavior = GKBehavior(goals: goals, andWeights: [1, 0])
        agent.behavior = behavior
        let position = node?.position
        agent.maxSpeed = 400
        agent.maxAcceleration = 400
        agent.radius = 40
        agent.position = vector_float2(Float(position?.x ?? 0), Float(position?.y ?? 0))
        agent.delegate = self
        return agent
    }
    
    func setupStateMachine(with agent: GKAgent2D, seekGoal: GKGoal, fleeGoal: GKGoal) {
        let fleeingState = FleeingState(with: agent, seekGoal: seekGoal, fleeGoal: fleeGoal, node: node as! SKSpriteNode)
        let seekState = SeekingState(with: agent, seekGoal: seekGoal, fleeGoal: fleeGoal, node: node as! SKSpriteNode)
        
        stateMachine = GKStateMachine(states: [
            fleeingState,
            seekState
            ])
        
        stateMachine?.enter(SeekingState.self)
    }
    
    
}
