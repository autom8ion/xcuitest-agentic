import XCTest
import ScreenAssertions

/// Verified live: the catalog defaults to Name - Ascending on load, giving
/// "Sauce Labs Backpack - Black" as the first product. The catalog has more
/// than the six backpack color variants visible in the first viewport — it
/// also includes a "Test.allTheThings() T-Shirt" line, whose "Yellow"
/// variant sorts after every "Sauce Labs Backpack" name descending (T > S)
/// and so is the true first item in that order, not
/// "Sauce Labs Backpack - Yellow" as a glance at only the visible grid
/// would suggest. Sorting is asserted by checking the first grid item
/// actually changes, not just that the sort menu's selection state changes
/// — a real behavioral check, not a cosmetic one.
final class CatalogSortingTests: MyDemoAppUITestCase {
    func testDefaultSortIsNameAscending() {
        let catalog = screen(CatalogScreen.self)
        ScreenAssertions.assertThat(catalog.productName(atIndex: 0)).hasLabel("Sauce Labs Backpack - Black")
    }

    func testSortByNameDescendingReversesTheOrder() {
        let catalog = screen(CatalogScreen.self)
        catalog.sortBy(.nameDescending)

        ScreenAssertions.assertThat(catalog.productName(atIndex: 0)).hasLabel("Test.allTheThings() T-Shirt - Yellow")
    }

    /// The six catalog variants are the same product at the same price
    /// (verified live), so price sort isn't guaranteed to visibly reorder
    /// them — a stable sort over equal keys leaves them as-is. What's
    /// genuinely verifiable is that choosing the option applies it: the
    /// popup closes, the catalog stays intact, and — confirmed live that
    /// selection state persists on `CatalogViewController`'s button
    /// instances across the popup being re-added — reopening the sort menu
    /// shows that option now marked `Selected`.
    func testSortByPriceAscendingSelectsThatOption() {
        let catalog = screen(CatalogScreen.self)
        catalog.sortBy(.priceAscending)
        ScreenAssertions.assertThat(catalog.screenContainer).isVisible()

        catalog.openSortMenu()
        ScreenAssertions.assertThat(catalog.sortOptionButton(.priceAscending)).isSelected()
    }

    func testSortByPriceDescendingSelectsThatOption() {
        let catalog = screen(CatalogScreen.self)
        catalog.sortBy(.priceDescending)
        ScreenAssertions.assertThat(catalog.screenContainer).isVisible()

        catalog.openSortMenu()
        ScreenAssertions.assertThat(catalog.sortOptionButton(.priceDescending)).isSelected()
    }

    func testReturningToNameAscendingRestoresTheOriginalOrder() {
        let catalog = screen(CatalogScreen.self)
        catalog.sortBy(.nameDescending)
        ScreenAssertions.assertThat(catalog.productName(atIndex: 0)).hasLabel("Test.allTheThings() T-Shirt - Yellow")

        catalog.sortBy(.nameAscending)
        ScreenAssertions.assertThat(catalog.productName(atIndex: 0)).hasLabel("Sauce Labs Backpack - Black")
    }
}
