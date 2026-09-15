---
name: app-notes
description: Verified facts and quirks about the bundled demo app (saucelabs/my-demo-app-ios) so agents don't have to re-discover them live every time. Read before exploring; append when you learn something new.
---

# App notes: My Demo App (iOS)

Bundle identifier: `com.saucelabs.mydemo.app.ios`. Source: `saucelabs/my-demo-app-ios` (native UIKit/storyboards, not SwiftUI), fetched by `scripts/setup-demo-app.sh` into gitignored `.demo-app/`, never committed. Everything below was verified directly against that source and/or a live simulator run — not assumed.

## Launch behavior

- **The app launches on the Catalog screen, not Login.** There is no login gate for browsing.
- The app supports UIKit scene state restoration. `AppUnderTest.launch()` always passes `-ApplePersistenceIgnoreState YES` to force a true cold start on the Catalog screen — without it, a relaunch resumes on whatever screen the app last showed (verified: it resumed on Cart after an earlier session had navigated there).

## Navigation map (verified)

- `Catalog-tab-item` / `Cart-tab-item` / `More-tab-item`: present on nearly every screen (Catalog, Cart, Product Details, Login, and screens under the More menu).
- **Login screen is reached two ways only:**
  1. `More-tab-item` → `MoreMenuScreen` → `LogOut-menu-item` (the menu's "Log Out" entry doubles as "Log In" — it always pushes `LoginViewController` regardless of current auth state; see `MenuViewController.logoutButton` in the app source).
  2. `CartScreen.proceedToCheckoutButton` when not authenticated (`MyCartViewController.preccedToCheckoutButton` sets `isFromProcessCheckout = true` before pushing Login; a successful login from that path routes straight to `ShippingAddressScreen` instead of back to Catalog).
- Login accepts **any non-empty username/password** — there's no real backend auth (`LoginViewController.LoginButton`). Empty-field validation shows a `UIAlertController` with message "Username is required" / "Password is required".

## Confirmed defect: the on-screen keyboard cannot be dismissed, and it blocks real flows

This is the single most important thing to know about this app before writing a new Screen that involves typing. It blocks `LoginScreen`'s manual entry path entirely and `ShippingAddressScreen` past its first three fields.

**The mechanism:** the app implements no tap-to-dismiss-keyboard gesture anywhere (verified: no `UIGestureRecognizer`/`endEditing` in the source), no return-key handling (`UITextFieldDelegate` isn't adopted anywhere), and no keyboard-avoidance layout. Once any field is focused, the on-screen keyboard occupies roughly the bottom 34% of the screen (key rows start around y=561 on a 852pt-tall device) and **never moves or dismisses** until the field is explicitly resigned some other way. Any control whose frame falls in that region becomes `isHittable == false` and a `.tap()` on it silently does nothing (not even a stray keystroke on the underlying keyboard key — it appears the touch is simply not delivered).

**Nine independent dismissal techniques were tried live against `LoginScreen`'s Login button and none worked:**
1. `XCUIElement.swipeDown()` on the keyboard — this is an iPad-only "undock the floating keyboard" gesture; iPhone keyboards are docked and don't respond to it.
2. Sending a Return keypress (`typeText("\n")`) — does nothing without an app-level delegate wired to resign on return, which this app doesn't have.
3. Tapping a coordinate above the keyboard (e.g. the app logo) — tapping a plain view with no gesture recognizer doesn't resign first responder in UIKit; that's app code the app doesn't have.
4. `app.typeKey(.escape, modifierFlags: [])` — no effect.
5. Backgrounding via `XCUIDevice.shared.press(.home)` then `app.activate()` — the keyboard-up state survived the cycle.
6. A forced raw coordinate tap via `XCUICoordinate` (bypassing the element's hittability check entirely) — no effect, and didn't even register as a stray keystroke.
7. A long press-and-drag from inside the keyboard to well above it — no effect (same "no undock gesture on iPhone" reason as #1).
8. Toggling `ConnectHardwareKeyboard` at the host level to try to suppress the on-screen keyboard's rendering entirely — `xcodebuild test` still renders and requires the on-screen keyboard for `typeText` regardless of this preference.
9. Trying a taller device (iPhone 16 Pro Max) on the theory the keyboard might not reach the button — it does; the form's layout scales with screen height, so the relative overlap is the same.

**The one thing that does work:** the app's own storyboard-provided quick-login buttons (`bob@example.com`, `alice@example.com`, `john@example.com`, `visual@example.com`, wired to `LoginViewController.emailButton`) set both text fields' values programmatically and never focus a field or raise the keyboard at all — so the Login button stays hittable. `LoginScreen.quickLogin(as:)` uses this. There is no equivalent quick-fill for `ShippingAddressScreen` or `PaymentScreen`.

**Practical impact on coverage:**
- `LoginScreen.login(username:password:)` (manual typing) can fill both fields but its submit step is confirmed permanently blocked — `LoginTests.testManualEntrySubmitIsBlockedByUnavoidableKeyboardOverlap` and the two empty-field validation tests document this with `XCTSkip` rather than silently not testing manual entry.
- `ShippingAddressScreen`: only `fullName`/`address1`/`address2` (all above the keyboard's boundary) are reliably fillable. `city`/`stateRegion` sit right at the boundary and were confirmed to intermittently fail to take focus once the keyboard is already up; `zipCode`/`country` sit fully within the covered region and reliably fail. `CheckoutFlowTests.testGuestCheckoutReachesShippingForm` verifies everything up through filling those three fields, then documents the rest as blocked via `XCTSkip`.
- Payment/Review/Checkout Complete screens have never been reached in a verified run as a result — their Screens exist (built from source/storyboard inspection) but are **unverified**, not confirmed. Treat them the way the generator treats any never-live-verified identifier: a starting point, not a guarantee.

If a future healer/maintainer run finds the app has changed (e.g. a dismiss gesture was added, or a scrollview with keyboard avoidance), re-verify this whole section live before trusting it — this was all confirmed against one specific build and could change.

## The catalog has more than the six backpack variants

A glance at the first viewport of `Catalog-screen` only shows six "Sauce Labs Backpack" color variants, and it's tempting to assume that's the whole catalog. It isn't — there's at least a "Test.allTheThings() T-Shirt" line too (confirmed live: sorting Name - Descending surfaces `"Test.allTheThings() T-Shirt - Yellow"` as the first item, not `"Sauce Labs Backpack - Yellow"`, because `T` sorts after `S`). Don't assume the product set from a single unscrolled dump — if a test needs to reason about "the last item" or "all products," scroll the collection view or check the sort-reversed order live first.

## A source-only reading was wrong about the cart's empty state

Worth keeping as a reminder to verify live even when the source looks conclusive. `MyCartViewController.viewDidLoad` only *appears* to gate the "No Items" empty state on load (`if cartList.count == 0 { tvContView.isHidden = true; ... }`), with `deleteProduct` never touching those `isHidden` flags when it removes the last item. Reading only that code, the reasonable prediction is: removing the last item leaves the (now-stale) item list/total UI showing rather than switching to the empty state, until a fresh visit re-runs `viewDidLoad`. Live testing showed this prediction was wrong — the empty state ("No Items", `CartEmpty Icons`, "Go Shopping") appears immediately after removing the last item, on the same screen instance, and the total/"N Items" bar is gone at that point too (not just stale — actually absent from the tree). The exact mechanism wasn't tracked down further; the point is the source reading undersold what actually happens, so `CartManagementTests` asserts the live behavior, not the source-predicted one.

## Verified accessibility identifiers by screen

| Screen | Element | Locator |
|---|---|---|
| Catalog | container | `otherElements["Catalog-screen"]` |
| Catalog | product cell | `otherElements.matching(identifier: "ProductItem")` |
| Catalog | product name/price/image | `identifier: "Product Name"/"Product Price"/"Product Image"` (label carries the real text, e.g. "Sauce Labs Backpack - Orange") |
| Product Details | container | `otherElements["ProductDetails-screen"]` |
| Product Details | Add to Cart | `buttons.matching(identifier: "AddToCart")` (NOT the app's own `PageObject.swift`, which uses the stale label "Add To Cart" — see below) |
| Product Details | price | `staticTexts.matching(identifier: "Price")` |
| Product Details | quantity | `staticTexts.matching(identifier: "Amount")` (label is the digit, e.g. `"1"`); `buttons["SubtractMinus Icons"]` / `buttons["AddPlus Icons"]` to adjust it — no identifiers on the stepper buttons |
| Product Details | color swatches | `buttons["<Color>ColorUnSelected Icons"]` for Green/Blue/Black/Gray — the label keeps the `UnSelected` suffix even when that swatch *is* selected (selection is the separate `Selected` accessibility trait, not part of the label; default selected is Green) |
| Product Details | rating stars | 5 buttons sharing the label `"StarSelected Icons"` or `"StarUnSelected Icons"` depending on fill state — address a specific star by position via `.matching(NSPredicate(...)).element(boundBy:)`, not by label alone |
| Catalog | sort trigger | `otherElements["Catalog-screen"].buttons["Button"]` — generic label shared with an unrelated button on `LoginScreen`, must be scoped to the Catalog container |
| Catalog | sort options | `buttons["Name - Ascending"/"Name - Descending"/"Price - Ascending"/"Price - Descending"]` — the popup renders as a *sibling* of `Catalog-screen`, not nested in it, so these are queried unscoped; the active one carries the `Selected` trait and that state persists on `CatalogViewController`'s button instances even after the popup is removed/re-added |
| Cart | container | `otherElements["Cart-screen"]` |
| Cart | Go Shopping | `buttons["GoShopping"]` |
| Cart | Proceed to Checkout | `buttons["ProceedToCheckout"]` |
| Cart | item count | `staticTexts["<N> Items"]` (label text, not an identifier) — this whole total/count bar disappears once the cart is empty, replaced by the empty-state content; don't expect it to still be queryable after removing the last item |
| Cart | line-item Remove/quantity | `buttons["Remove Item"]`, `buttons["SubtractMinus Icons"]`, `buttons["AddPlus Icons"]` — all label-only, shared across every row; `firstMatch` is correct for a single-item cart only |
| More menu sub-screens | containers | `otherElements["About-screen"/"GeoLocation-screen"/"Drawing-screen"/"Webview-screen"/"QrCodeScanner-screen"]` |
| GeoLocation | fixed demo coordinates | `staticTexts["13.45143"]` (longitude), `staticTexts["52.50032"]` (latitude) — not device-derived, safe to assert on directly |
| Drawing | canvas/controls | `images["DrawingBackground Icons"]`, `buttons["ClearButton Icons"]`, `buttons["SaveButton Icons"]` |
| Reset App State | confirmation alert | `alerts["Reset App State"]`, `alerts.buttons["RESET APP"]` / `alerts.buttons["CANCEL"]` — confirming clears the cart and shipping/payment info app-wide (`MenuViewController.resetAppState`); this was verified to actually take effect immediately, unlike the cart's own delete-triggered empty state, which was *also* verified to update immediately (see below) despite an initial source-only reading suggesting otherwise |
| Login | username field | `textFields.element(boundBy: 0)` — no identifier exists; only textField on screen |
| Login | password field | `secureTextFields.element(boundBy: 0)` — no identifier exists; only secureTextField on screen |
| Login | Login button | `buttons["Login"]` — label match, no identifier |
| Login | quick-login buttons | `buttons["bob@example.com"/"alice@example.com"/"john@example.com"/"visual@example.com"]` — the reliable way to authenticate; see the keyboard-defect section above |
| More menu | Log Out/Log In | `buttons["LogOut-menu-item"]` |
| Shipping | container | `otherElements["ShippingAddress-screen"]` |
| Shipping | 7 fields, verified order | indexed `textFields` within the container: `fullName`(0), `address1`(1), `address2`(2), `city`(3), `zipCode`(4), `stateRegion`(5), `country`(6). **Not** `@IBOutlet` declaration order — verified live via a full accessibility dump keyed off each field's placeholder text. The last 4 form a 2x2 grid queried column-first (left column top-to-bottom, then right column top-to-bottom), which is why zip(4)/state(5) are swapped relative to what declaration order or a row-major glance would suggest. Only fields 0-2 are reliably fillable — see the keyboard-defect section above. |
| Shipping | To Payment | `buttons["To Payment"]` — label match |
| Payment | container | `otherElements["Payment-screen"]` |
| Payment | 4 card fields | indexed `textFields` within the container: fullNameOnCard, cardNumber, expirationDate, securityCode. The billing-address sub-form defaults hidden (`PaymentMethodViewController.viewDidLoad`: `billingAddresBtn.isSelected = true`), so it's excluded from the accessibility tree and these 4 indices are unambiguous **by source inspection** — order not live-verified (never reached; see keyboard-defect section) and could have the same column-first grid surprise Shipping had. |
| Payment | Review Order | `buttons["Review Order"]` — label match, not live-verified |
| Review Order | Place Order | `buttons["Place Order"]` — label match; the screen's own container has no identifier; not live-verified |
| Checkout Complete | container | `otherElements["CheckoutComplete-screen"]`; not live-verified |
| Checkout Complete | Continue Shopping | `buttons["ContinueShopping"]`; not live-verified |

## Known drift in the app's own PageObject.swift

`MyDemoAppUITests/PageObjects/PageObject.swift` (shipped in the app's own repo) is **not fully reliable** — it has no corresponding `LoginTest.swift` in the app's own test suite, so nothing has caught its drift:
- `logOutScreen = app.otherElements["LogOut-screen"]` references an identifier that doesn't exist anywhere in the app's storyboards or source. Don't copy it.
- `addToCartButton = productDetailsScreen.buttons["Add To Cart"]` uses a label match; the storyboard actually assigns this button the identifier `AddToCart` (no space), which is more precise — prefer that.

Treat the app's own PageObject.swift as a rough hint at best, never a verified source — everything in the table above was cross-checked against the actual storyboards/controllers or a live run.
