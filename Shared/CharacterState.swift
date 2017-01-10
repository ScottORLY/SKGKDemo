import GameplayKit
import SpriteKit

class CharacterState: GKState {
    
    weak var node: SKSpriteNode?
    weak var agent: GKAgent2D?
    
    let seekGoal: GKGoal
    let fleeGoal: GKGoal
    let originalTexture: SKTexture?
    
    init(with agent: GKAgent2D, seekGoal: GKGoal, fleeGoal: GKGoal, node: SKSpriteNode) {
        self.agent = agent
        self.seekGoal = seekGoal
        self.fleeGoal = fleeGoal
        self.node = node
        self.originalTexture = node.texture
    }
}

class SeekingState: CharacterState {
    
    override func didEnter(from previousState: GKState?) {
       agent?.behavior?.setWeight(1, for: seekGoal)
    }
    
    override func willExit(to nextState: GKState) {
        agent?.behavior?.setWeight(0, for: seekGoal)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is FleeingState.Type
    }
}

class FleeingState: CharacterState {
    let fleeingTexture = SKTexture(imageNamed: "runaway")
    
    override func didEnter(from previousState: GKState?) {
        node?.texture = fleeingTexture
        agent?.behavior?.setWeight(1, for: fleeGoal)
    }
    
    override func willExit(to nextState: GKState) {
        node?.texture = originalTexture
        agent?.behavior?.setWeight(0, for: fleeGoal)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is SeekingState.Type
    }
}
