import GameplayKit

class EnemyAgent: GKComponent, GKAgentDelegate {
    
    func agentDidUpdate(_ agent: GKAgent) {
        
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
        if let agent = agent as? GKAgent2D {
            node?.position.x = CGFloat(agent.position.x)
        }
    }
    
}
