import XCTest
import ScreenObject

/// The "More" menu (`Menu.storyboard`), reached via the `More-tab-item`
/// present on most screens. Its "Log Out" entry is the app's only way to
/// reach `LoginScreen` outside of the checkout flow — confirmed in
/// `MenuViewController.logoutButton`, which pushes `LoginViewController`
/// regardless of current auth state (it doubles as "Log In").
///
/// `Crash the App` and `FaceID`/Biometrics are deliberately not exposed
/// here: the former terminates the process (not something to automate in
/// routine coverage) and the latter requires simulator biometric
/// enrollment to interact with meaningfully. `Push Notifications` is
/// likewise omitted — it can trigger a one-time-only native OS permission
/// prompt on first navigation, which behaves inconsistently across runs.
public final class MoreMenuScreen: Screen {
    public var logOutButton: ScreenElement { element { self.app.buttons["LogOut-menu-item"] } }
    public var webviewButton: ScreenElement { element { self.app.buttons["Webview-menu-item"] } }
    public var qrCodeScannerButton: ScreenElement { element { self.app.buttons["QrCodeScanner-menu-item"] } }
    public var geoLocationButton: ScreenElement { element { self.app.buttons["GeoLocation-menu-item"] } }
    public var drawingButton: ScreenElement { element { self.app.buttons["Drawing-menu-item"] } }
    public var aboutButton: ScreenElement { element { self.app.buttons["About-menu-item"] } }
    public var resetAppStateButton: ScreenElement { element { self.app.buttons["ResetAppState-menu-item"] } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }
    public var cartTabItem: ScreenElement { element { self.app.buttons["Cart-tab-item"] } }

    public func goToLogin() { logOutButton.tap() }
    public func goToWebview() { webviewButton.tap() }
    public func goToQrCodeScanner() { qrCodeScannerButton.tap() }
    public func goToGeoLocation() { geoLocationButton.tap() }
    public func goToDrawing() { drawingButton.tap() }
    public func goToAbout() { aboutButton.tap() }

    /// Opens the confirmation alert (`MenuViewController.resetAppStateButton`)
    /// — does not itself confirm or cancel it.
    public func openResetAppStateConfirmation() { resetAppStateButton.tap() }

    public var resetAppStateAlert: ScreenElement { element { self.app.alerts["Reset App State"] } }
    public var confirmResetAppStateButton: ScreenElement { element { self.app.alerts.buttons["RESET APP"] } }
    public var cancelResetAppStateButton: ScreenElement { element { self.app.alerts.buttons["CANCEL"] } }

    /// Opens the confirmation alert and confirms it — clears the cart and
    /// shipping/payment info app-wide (`MenuViewController.resetAppState`).
    public func resetAppState() {
        openResetAppStateConfirmation()
        confirmResetAppStateButton.tap()
    }

    public func cancelResetAppState() {
        openResetAppStateConfirmation()
        cancelResetAppStateButton.tap()
    }
}
