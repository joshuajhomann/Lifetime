import Combine

public extension Task {
    var cancellable: AnyCancellable { .init(cancel) }
}
