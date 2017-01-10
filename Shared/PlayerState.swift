import GameplayKit

class PowerupState: GKState  {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is VulnerableState.Type
    }
}

class VulnerableState: GKState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is PowerupState.Type
    }
}
