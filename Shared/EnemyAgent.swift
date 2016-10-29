import GameplayKit

class EnemyAgent: GKComponent, GKAgentDelegate {
    
    var stateMachine: GKStateMachine?
    weak var agent: GKAgent?
    
    override func update(deltaTime seconds: TimeInterval) {
        if stateMachine == nil {
            stateMachine = GKStateMachine(states:
                [
                    WalkingState(with: node!, name: "SlimeMove"),
                    HitState(with: node!, name: "slimePurple_hit")
                ]
            )
            stateMachine?.enter(WalkingState.self)
        }
        stateMachine?.update(deltaTime: seconds)
    }
    
    func hitMe() {
        stateMachine?.enter(HitState.self)
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        if !(stateMachine?.currentState is HitState), let agent = agent as? GKAgent2D  {
            node?.position.x = CGFloat(agent.position.x)
        }
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
      
    }
}
