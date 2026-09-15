import XCTest
import ScreenObject

/// The product catalog (`Catalog-screen`, `TabBar.storyboard`).
///
/// Sorting (verified live): the trigger button carries no identifier and
/// the generic label `"Button"` (shared with an unrelated button on
/// `LoginScreen`), so it's queried scoped to `screenContainer`. The sort
/// popup itself renders as a *sibling* of `Catalog-screen` in the tree, not
/// nested inside it, so its four options are queried unscoped at `app`
/// level — their labels (`"Name - Ascending"` etc.) are unique app-wide.
/// Default sort on load is Name - Ascending.
public final class CatalogScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["Catalog-screen"] } }
    public var products: ScreenElementList { elements { self.app.otherElements.matching(identifier: "ProductItem") } }
    public var cartTabItem: ScreenElement { element { self.app.buttons["Cart-tab-item"] } }
    public var moreTabItem: ScreenElement { element { self.app.buttons["More-tab-item"] } }
    public var sortTriggerButton: ScreenElement {
        element { self.app.otherElements["Catalog-screen"].buttons["Button"] }
    }

    public enum SortOption: String {
        case nameAscending = "Name - Ascending"
        case nameDescending = "Name - Descending"
        case priceAscending = "Price - Ascending"
        case priceDescending = "Price - Descending"
    }

    public func sortOptionButton(_ option: SortOption) -> ScreenElement {
        element { self.app.buttons[option.rawValue] }
    }

    public func product(named name: String) -> ScreenElement {
        element { self.app.staticTexts[name] }
    }

    /// The visible product name at `index` (0-based, matching catalog grid
    /// order) — read this after sorting to verify the new order.
    public func productName(atIndex index: Int) -> ScreenElement {
        element {
            self.app.otherElements.matching(identifier: "ProductItem")
                .element(boundBy: index)
                .staticTexts.matching(identifier: "Product Name").firstMatch
        }
    }

    public func openProduct(atIndex index: Int) {
        products.at(index).tap()
    }

    public func openProduct(named name: String) {
        product(named: name).tap()
    }

    public func goToCart() { cartTabItem.tap() }
    public func openMoreMenu() { moreTabItem.tap() }

    public func openSortMenu() { sortTriggerButton.tap() }

    public func sortBy(_ option: SortOption) {
        openSortMenu()
        sortOptionButton(option).tap()
    }
}
