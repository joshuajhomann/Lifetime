# Lifetime

This package adds a `lifetime` modifier to SwiftUI views that starts a `@MainActor` `Task` that is scoped to the lifetime of the view, unlike `.task` which is scoped to the visibility of the view.

It also adds `sink` and `assign` methods to `AsyncSequence` that return `AnyCancellable` as well as `sink` and `assign` methods that can be scoped to a lifetime (inspired by ReactiveSwift), obviating the need to store the `AnyCancellable`.

## Usage

### Lifetime modifier
```
var body: some View {
    Text("Hello world")
        .lifetime { lifetime in
            await viewModel(lifetime)
        }
```

### Subscription
```
func callAsFunction(_ lifetime: some Lifetime) async {
    inputAsyncSequence.assign(during: lifetime, to: \.output, on: self)
}
```

### Subscription Builder:
```
func callAsFunction(_ lifetime: some Lifetime) async {
    subscribe(during: lifetime) {
        inputAsyncSequence1.assign(to: \.output1, on: self)
        inputAsyncSequence2.assign(to: \.output2, on: self)
    }
}
```
