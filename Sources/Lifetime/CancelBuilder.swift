import Combine

@resultBuilder
public struct CancelBuilder {
    typealias Expression = AnyCancellable
    typealias Component = [AnyCancellable]
    static func buildExpression(_ expression: Expression) -> Component { [expression] }
    static func buildPartialBlock(first: Component) -> Component { first }
    static func buildPartialBlock(accumulated: Component, next: Component) -> Component { accumulated + next }
}
