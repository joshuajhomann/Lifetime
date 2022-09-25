//
//  File.swift
//  
//
//  Created by Joshua Homann on 9/25/22.
//

import Combine

public extension AsyncSequence {
    func assign<Target: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Target, Element>,
        on target: Target,
        onError: @escaping (Error) -> Void = { _ in }
    ) -> AnyCancellable {
        sink(receiveError: onError) { [weak target] value in
            target?[keyPath: keyPath] = value
        }
    }

    func sink(
        complete: @MainActor @escaping () -> Void = { },
        receiveError onError: @MainActor @escaping (Error) -> Void = { _ in },
        receiveValue observe: @MainActor @escaping (Element) -> Void
    ) -> AnyCancellable {
        Task { @MainActor in
            do {
                for try await value in self { observe(value) }
                complete()
            } catch {
                onError(error)
            }
        }.cancellable
    }

    func assign<Target: AnyObject>(
        during lifetime: some Lifetime,
        to keyPath: ReferenceWritableKeyPath<Target, Element>,
        on target: Target,
        onError: @escaping (Error) -> Void = { _ in }
    ) {
        sink(during: lifetime, receiveError: onError) { [weak target] value in
            target?[keyPath: keyPath] = value
        }
    }

    func sink(
        during lifetime: some Lifetime,
        complete: @MainActor @escaping () -> Void = { },
        receiveError onError: @MainActor @escaping (Error) -> Void = { _ in },
        receiveValue observe: @MainActor @escaping (Element) -> Void
    ) {
        var subscriptions = [sink(complete: complete, receiveError: onError, receiveValue: observe)]
        lifetime
            .sink { _ in subscriptions.removeAll() } receiveValue: { _ in }
            .store(in: &subscriptions)
    }
}
