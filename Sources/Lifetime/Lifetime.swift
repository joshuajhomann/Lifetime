import Combine
import SwiftUI

public typealias Lifetime = Publisher<Never, Never>

final class LifetimeViewModel: ObservableObject {
    private var didPerform = false
    private var cancellable: AnyCancellable?
    func performOnce(_ operation: @escaping (any Lifetime) async -> Void) {
        guard !didPerform else { return }
        didPerform = true
        let lifetimeEndedSubject = PassthroughSubject<Never, Never>()
        let task = Task { @MainActor in
            await operation(lifetimeEndedSubject)
        }
        cancellable = .init {
            lifetimeEndedSubject.send(completion: .finished)
            task.cancel()
        }
    }
}

struct LifetimeViewModifier: ViewModifier {
    @StateObject private var viewModel = LifetimeViewModel()
    var operation: (any Lifetime) async -> Void
    func body(content: Content) -> some View {
        content.onAppear { viewModel.performOnce(operation) }
    }
}

public extension View {
    func lifetime(_ operation: @escaping (any Lifetime) async -> Void) -> some View {
        modifier(LifetimeViewModifier(operation: operation))
    }
}
