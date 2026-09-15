import XCTest
import ScreenObject

/// A single product's detail page (`ProductDetails-screen`). Verified live
/// (see `.claude/skills/app-notes`) — quantity, color, and rating controls
/// all carry only labels, no identifiers, and the label text for a color
/// button stays `"<Color>ColorUnSelected Icons"` even when that color *is*
/// selected (selection is a separate accessibility trait, not part of the
/// label) — confirmed by the default state, where Green shows `Selected`
/// but its label is still `"GreenColorUnSelected Icons"`.
public final class ProductDetailsScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["ProductDetails-screen"] } }
    public var addToCartButton: ScreenElement {
        element { self.app.buttons.matching(identifier: "AddToCart").firstMatch }
    }
    public var priceLabel: ScreenElement {
        element { self.app.staticTexts.matching(identifier: "Price").firstMatch }
    }
    public var amountLabel: ScreenElement {
        element { self.app.staticTexts.matching(identifier: "Amount").firstMatch }
    }
    public var increaseAmountButton: ScreenElement {
        element { self.screenElement.buttons["AddPlus Icons"] }
    }
    public var decreaseAmountButton: ScreenElement {
        element { self.screenElement.buttons["SubtractMinus Icons"] }
    }
    public var productHighlights: ScreenElement {
        element { self.screenElement.staticTexts["Product Highlights"] }
    }
    public var cartTabItem: ScreenElement { element { self.app.buttons["Cart-tab-item"] } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }

    private var screenElement: XCUIElement { app.otherElements["ProductDetails-screen"] }

    public enum ProductColor: String {
        case green = "Green", blue = "Blue", black = "Black", gray = "Gray"

        var buttonLabel: String { "\(rawValue)ColorUnSelected Icons" }
    }

    public func colorButton(_ color: ProductColor) -> ScreenElement {
        element { self.screenElement.buttons[color.buttonLabel] }
    }

    /// A star in the rating row, 1-indexed (1...5) to match how a person
    /// would describe "the 3rd star" rather than a 0-based array index.
    public func ratingStar(_ position: Int) -> ScreenElement {
        element {
            self.screenElement.buttons.matching(
                NSPredicate(format: "label == 'StarSelected Icons' OR label == 'StarUnSelected Icons'")
            ).element(boundBy: position - 1)
        }
    }

    public func titleLabel(_ productName: String) -> ScreenElement {
        element { self.app.staticTexts[productName] }
    }

    public func addToCart() { addToCartButton.tap() }
    public func goToCart() { cartTabItem.tap() }
    public func backToCatalog() { catalogTabItem.tap() }
    public func increaseAmount() { increaseAmountButton.tap() }
    public func decreaseAmount() { decreaseAmountButton.tap() }
    public func selectColor(_ color: ProductColor) { colorButton(color).tap() }
    public func rate(stars position: Int) { ratingStar(position).tap() }
}
