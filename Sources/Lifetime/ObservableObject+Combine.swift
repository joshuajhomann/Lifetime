import Combine

public extension ObservableObject {
    func store(
        in keyPath: ReferenceWritableKeyPath<Self, some RangeReplaceableCollection<AnyCancellable>>,
        @CancelBuilder build: () -> [AnyCancellable]
    ) {
        build().forEach { $0.store(in: &self[keyPath: keyPath]) }
    }

    func store(
        in keyPath: ReferenceWritableKeyPath<Self, some SetAlgebra<AnyCancellable>>,
        @CancelBuilder build: () -> [AnyCancellable]
    ) {
        build().forEach { self[keyPath: keyPath].insert($0) }
    }

    func subscribe(
        during lifetime: some Lifetime,
        @CancelBuilder build: () -> [AnyCancellable]
    ) {
        var subscriptions = build()
        lifetime
            .sink { _ in subscriptions.removeAll() } receiveValue: { _ in }
            .store(in: &subscriptions)
    }
}
