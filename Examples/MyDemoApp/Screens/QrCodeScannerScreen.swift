import XCTest
import ScreenObject

/// The QR Code Scanner screen (`QrCodeScanner-screen`). Kept to
/// navigation/presence checks — actually scanning needs a real camera feed,
/// which isn't meaningfully automatable in a simulator.
public final class QrCodeScannerScreen: Screen {
    public var screenContainer: ScreenElement { element { self.app.otherElements["QrCodeScanner-screen"] } }
    public var catalogTabItem: ScreenElement { element { self.app.buttons["Catalog-tab-item"] } }

    public func backToCatalog() { catalogTabItem.tap() }
}
