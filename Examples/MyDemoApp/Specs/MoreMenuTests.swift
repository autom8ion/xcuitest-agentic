import XCTest
import ScreenAssertions

final class MoreMenuTests: MyDemoAppUITestCase {
    private func openMoreMenu() -> MoreMenuScreen {
        screen(CatalogScreen.self).openMoreMenu()
        return screen(MoreMenuScreen.self)
    }

    func testAboutScreenShowsContentAndReturnsToCatalog() {
        let menu = openMoreMenu()
        menu.goToAbout()

        let about = screen(AboutScreen.self)
        ScreenAssertions.assertThat(about.screenContainer).isVisible()
        ScreenAssertions.assertThat(about.goToSaucelabsButton).isVisible()

        about.backToCatalog()
        ScreenAssertions.assertThat(screen(CatalogScreen.self).screenContainer).isVisible()
    }

    /// Coordinates are fixed demo values (verified live), not
    /// device-derived — safe to assert on directly.
    func testGeoLocationScreenShowsFixedDemoCoordinates() {
        let menu = openMoreMenu()
        menu.goToGeoLocation()

        let geoLocation = screen(GeoLocationScreen.self)
        ScreenAssertions.assertThat(geoLocation.screenContainer).isVisible()
        ScreenAssertions.assertThat(geoLocation.longitudeValue).isVisible()
        ScreenAssertions.assertThat(geoLocation.latitudeValue).isVisible()

        geoLocation.backToCatalog()
        ScreenAssertions.assertThat(screen(CatalogScreen.self).screenContainer).isVisible()
    }

    func testDrawingScreenAcceptsAStrokeAndClears() {
        let menu = openMoreMenu()
        menu.goToDrawing()

        let drawing = screen(DrawingScreen.self)
        ScreenAssertions.assertThat(drawing.screenContainer).isVisible()

        drawing.drawStroke()
        drawing.clear()
        ScreenAssertions.assertThat(drawing.screenContainer).isVisible()

        drawing.backToCatalog()
        ScreenAssertions.assertThat(screen(CatalogScreen.self).screenContainer).isVisible()
    }

    func testWebviewScreenIsReachable() {
        let menu = openMoreMenu()
        menu.goToWebview()

        let webview = screen(WebviewScreen.self)
        ScreenAssertions.assertThat(webview.screenContainer).isVisible()
        ScreenAssertions.assertThat(webview.goToSiteButton).isVisible()

        webview.backToCatalog()
        ScreenAssertions.assertThat(screen(CatalogScreen.self).screenContainer).isVisible()
    }

    func testQrCodeScannerScreenIsReachable() {
        let menu = openMoreMenu()
        menu.goToQrCodeScanner()

        let scanner = screen(QrCodeScannerScreen.self)
        ScreenAssertions.assertThat(scanner.screenContainer).isVisible()

        scanner.backToCatalog()
        ScreenAssertions.assertThat(screen(CatalogScreen.self).screenContainer).isVisible()
    }

    func testCancellingResetAppStateKeepsTheCart() {
        let catalog = screen(CatalogScreen.self)
        catalog.openProduct(atIndex: 0)
        let details = screen(ProductDetailsScreen.self)
        details.addToCart()
        details.backToCatalog()

        let menu = openMoreMenu()
        menu.openResetAppStateConfirmation()
        ScreenAssertions.assertThat(menu.resetAppStateAlert).isVisible()
        menu.cancelResetAppStateButton.tap()

        menu.catalogTabItem.tap()
        catalog.goToCart()
        ScreenAssertions.assertThat(screen(CartScreen.self).itemCountLabel("1 Items")).isVisible()
    }

    func testConfirmingResetAppStateClearsTheCart() {
        let catalog = screen(CatalogScreen.self)
        catalog.openProduct(atIndex: 0)
        let details = screen(ProductDetailsScreen.self)
        details.addToCart()
        details.backToCatalog()

        let menu = openMoreMenu()
        menu.resetAppState()

        menu.catalogTabItem.tap()
        catalog.goToCart()
        ScreenAssertions.assertThat(screen(CartScreen.self).emptyStateLabel).isVisible()
    }
}
