import XCTest
import ScreenObject

/// The authentication screen (`Authentication.storyboard`).
///
/// This is **not** the app's launch screen — the app launches directly on
/// `CatalogScreen` (verified live: a fresh install with state restoration
/// disabled lands on Catalog, not Login). `LoginScreen` is reached two ways,
/// both verified against the app source:
///  1. `MoreMenuScreen.goToLogin()` (the "Log Out" menu entry doubles as
///     "Log In" — see `MenuViewController.logoutButton`)
///  2. Tapping "Proceed to Checkout" from `CartScreen` while unauthenticated
///     (`MyCartViewController.preccedToCheckoutButton`)
///
/// ## A confirmed, unworkaroundable app defect
///
/// The Login button's fixed frame (y≈692 on a 852pt-tall screen) overlaps
/// where the on-screen keyboard's key rows sit once *either* field is
/// focused, and the app implements no tap-to-dismiss gesture, no return-key
/// handling, and no keyboard-avoidance layout anywhere (verified against the
/// full app source — see `.claude/skills/app-notes`). Nine independent
/// dismissal techniques were tried live and none worked (swipe-to-dismiss —
/// not a thing on iPhone, only iPad; return key; tapping outside; Escape
/// key; background+reactivate; forced coordinate tap; a long press-drag;
/// hardware-keyboard passthrough). Once a field is focused, `loginButton`
/// genuinely cannot be tapped through the keyboard. This is a real product
/// limitation, not a locator or framework problem — see `login(username:password:)`.
///
/// The app's own storyboard-provided quick-login buttons
/// (`quickLogin(as:)`) sidestep this entirely: they set the text fields'
/// values programmatically (`LoginViewController.emailButton`) without ever
/// focusing a field or raising the keyboard, so `loginButton` stays
/// hittable. Prefer `quickLogin(as:)` for any Spec that just needs to be
/// logged in; reserve `login(username:password:)` for a test that
/// specifically exercises manual text entry (and expect it to only get as
/// far as typing — submitting is the confirmed-blocked step).
///
/// The username field, password field, and Login button carry no
/// `accessibilityIdentifier` in the app's storyboard. The username field is
/// the only element in `app.textFields` on this screen and the password
/// field the only one in `app.secureTextFields`, so the indexed queries
/// below are a documented exception to the identifier-first locator rule,
/// not a shortcut.
public final class LoginScreen: Screen {
    public var usernameField: ScreenElement { element { self.app.textFields.element(boundBy: 0) } }
    public var passwordField: ScreenElement { element { self.app.secureTextFields.element(boundBy: 0) } }
    public var loginButton: ScreenElement { element { self.app.buttons["Login"] } }
    public var validationAlert: ScreenElement { element { self.app.alerts.firstMatch } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }

    /// One of the app's four built-in quick-login identities (verified in
    /// `Authentication.storyboard`): `bob`, `alice`, `john`, `visual`, each
    /// `@example.com`. Fills both fields and submits without ever raising
    /// the keyboard — the reliable way to reach an authenticated state.
    public enum QuickLoginUser: String {
        case bob, alice, john, visual

        var buttonLabel: String { "\(rawValue)@example.com" }
    }

    public func quickLogin(as user: QuickLoginUser = .bob) {
        app.buttons[user.buttonLabel].tap()
        loginButton.tap()
    }

    /// Manual text entry. Only gets as far as typing into both fields —
    /// see the type-level doc comment. Do not chain `.submit()` after this
    /// expecting it to reach an authenticated state; it won't.
    public func login(username: String, password: String) {
        usernameField.typeText(username)
        passwordField.typeText(password)
    }

    /// Taps the Login button. Confirmed unreachable once a field has been
    /// focused (see the type-level doc comment) — calling this after
    /// `login(username:password:)` will not succeed. Safe to call with no
    /// field focused (e.g. right after `quickLogin`, though `quickLogin`
    /// already does this itself).
    public func submit() {
        dismissKeyboardIfPresent()
        loginButton.tap()
    }

    /// The Login screen still shows the tab bar, so a user can bail back to
    /// browsing without authenticating.
    public func returnToCatalogWithoutLoggingIn() {
        catalogTabItem.tap()
    }
}
