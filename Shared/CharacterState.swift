import GameplayKit
import SpriteKit

class CharacterState: GKState {
    
    weak var node: SKNode?
    let name: String

    init(with node: SKNode, name:String) {
        self.node = node
        self.name = name
    }
}

class WalkingState: CharacterState {
    
    override func didEnter(from previousState: GKState?) {
        let action = SKAction(named: name)
        node?.run(action!, withKey: "walking")
    }
    override func willExit(to nextState: GKState) {
        node?.removeAction(forKey: "walking")
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is StandingState.Type || stateClass is JumpingState.Type || stateClass is HitState.Type
    }
}

class JumpingState: CharacterState {
    
    override func didEnter(from previousState: GKState?) {
        let action = SKAction(named: name)
        node?.run(action!, withKey: "jumping")
    }
    override func willExit(to nextState: GKState) {
        node?.removeAction(forKey: "jumping")
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is WalkingState.Type || stateClass is StandingState.Type || stateClass is HitState.Type
    }
}

class StandingState: CharacterState {
    
    override func didEnter(from previousState: GKState?) {
        (node as? SKSpriteNode)?.texture = SKTexture(imageNamed: name)
    }
    override func willExit(to nextState: GKState) {
        
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is WalkingState.Type || stateClass is JumpingState.Type || stateClass is HitState.Type
    }
}

class HitState: CharacterState {
    
    var hitTimer: TimeInterval = 0
    
    override func update(deltaTime seconds: TimeInterval) {
        hitTimer += seconds
    }
    
    override func didEnter(from previousState: GKState?) {
        (node as? SKSpriteNode)?.texture = SKTexture(imageNamed: name)
        node?.physicsBody = nil
    }
    override func willExit(to nextState: GKState) {
        
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is WalkingState.Type || stateClass is JumpingState.Type || stateClass is StandingState.Type
    }
}
