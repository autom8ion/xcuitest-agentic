import XCTest
import ScreenObject

/// The shipping address form (`ShippingAddress-screen`). Requires being
/// logged in first (checkout forces `LoginScreen` if not authenticated).
///
/// None of the seven form fields carry an `accessibilityIdentifier` in the
/// app's storyboard. Field order (verified live via a full accessibility
/// dump, keyed off each field's placeholder text — NOT assumed from
/// `@IBOutlet` declaration order, which turned out to be misleading): the
/// first three (`fullName`, `address1`, `address2`) are full-width and
/// stacked, but `city`/`state`/`zip`/`country` are a 2x2 grid laid out as
/// two column-stacks, so the query order is **column-first**: `city` (top
/// of left column), `zipCode` (bottom of left column), `stateRegion` (top of
/// right column), `country` (bottom of right column) — not the row-major
/// order a glance at the screen would suggest. Queries are scoped to
/// `screenContainer` so they can't accidentally match a field on another
/// screen.
///
/// ## Confirmed: only the top 3 fields are reliably fillable
///
/// Like `LoginScreen`'s Login button, this form's lower fields sit where
/// the keyboard's key rows cover them once any field is focused, and the
/// app has the same no-dismiss-mechanism defect (see `LoginScreen`'s doc
/// comment for the full account). `fullName`/`address1`/`address2` sit
/// above the keyboard's boundary and are safe. `city`/`stateRegion` sit
/// right at the boundary and were confirmed live to intermittently fail to
/// take focus once the keyboard is already up from a prior field.
/// `zipCode`/`country` sit fully within the keyboard's covered region and
/// were confirmed to reliably fail. There is no quick-fill mechanism for
/// this form (unlike `LoginScreen.quickLogin`), so this is currently an
/// unresolved, documented blocker on full checkout automation — see
/// `.claude/skills/app-notes`.
public final class ShippingAddressScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["ShippingAddress-screen"] } }
    public var toPaymentButton: ScreenElement { element { self.app.buttons["To Payment"] } }

    private func field(_ index: Int) -> ScreenElement {
        element { self.app.otherElements["ShippingAddress-screen"].textFields.element(boundBy: index) }
    }

    public var fullNameField: ScreenElement { field(0) }
    public var address1Field: ScreenElement { field(1) }
    public var address2Field: ScreenElement { field(2) }
    public var cityField: ScreenElement { field(3) }
    public var zipCodeField: ScreenElement { field(4) }
    public var stateRegionField: ScreenElement { field(5) }
    public var countryField: ScreenElement { field(6) }

    /// Fills only the three fields confirmed reliably fillable (see the
    /// type-level doc comment). Does not attempt city/state/zip/country —
    /// callers that need the form fully submitted should expect to stop
    /// here and `XCTSkip` with a reference to the known blocker, the same
    /// way `CheckoutFlowTests` does.
    public func fillReliableFields(fullName: String, address1: String, address2: String = "") {
        fullNameField.typeText(fullName)
        address1Field.typeText(address1)
        if !address2.isEmpty { address2Field.typeText(address2) }
    }

    /// Dismisses the keyboard before tapping — the last-filled field's
    /// keyboard can otherwise cover "To Payment" the same way it covers
    /// `LoginScreen`'s Login button; see `Screen.dismissKeyboardIfPresent`.
    /// Confirmed not to actually help on this app (same as Login) — kept
    /// for the rare case a future app change makes it effective, and
    /// because it's a harmless no-op otherwise.
    public func proceedToPayment() {
        dismissKeyboardIfPresent()
        toPaymentButton.tap()
    }
}
