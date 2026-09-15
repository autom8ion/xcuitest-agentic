import XCTest

/// A re-resolving wrapper around an `XCUIElementQuery` matching zero or more
/// elements — e.g. a catalog's repeated `ProductItem` cells. Like
/// `ScreenElement`, it never caches: `at(_:)` returns a `ScreenElement` that
/// re-runs the full query on every access.
public struct ScreenElementList {
    private let resolve: () -> XCUIElementQuery

    public init(resolve: @escaping () -> XCUIElementQuery) {
        self.resolve = resolve
    }

    public var count: Int { resolve().count }

    public func at(_ index: Int) -> ScreenElement {
        ScreenElement(resolve: { self.resolve().element(boundBy: index) })
    }

    public func matching(label: String) -> ScreenElement {
        ScreenElement(resolve: {
            self.resolve().matching(NSPredicate(format: "label == %@", label)).firstMatch
        })
    }
}
