import GameplayKit

extension GKComponent {
    var node: SKNode? {
        return self.entity?.component(ofType: GKSKNodeComponent.self)?.node
    }
}
