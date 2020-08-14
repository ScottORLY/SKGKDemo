import GameplayKit

class EnemyAgent: GKComponent, GKAgentDelegate {

    lazy var node: SKNode? = {
        entity?.component(ofType: GKSKNodeComponent.self)?.node
    }()

    var stateMachine: GKStateMachine?
    var playerState: GKStateMachine?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override class var supportsSecureCoding: Bool {
        true
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if playerState?.currentState is PowerupState {
            stateMachine?.enter(FleeingState.self)
        } else {
            stateMachine?.enter(SeekingState.self)
        }
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        if let agent = agent as? GKAgent2D  {
            node?.position = CGPoint(x: CGFloat(agent.position.x), y: CGFloat(agent.position.y))
        }
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
        if let agent = agent as? GKAgent2D  {
            agent.position = float2(Float((node?.position.x)!), Float((node?.position.y)!))
        }
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
}
