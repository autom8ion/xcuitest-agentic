---
name: screen-object-conventions
description: How to structure a Screen Object class under Examples/*/Screens — element getters, action methods, no caching, no assertions.
---

# Screen Object conventions

A `Screen` subclass (`Sources/ScreenObject/Screen.swift`) has exactly two kinds of member:

1. **Element getters** — computed properties returning `ScreenElement` or `ScreenElementList`, built via `element { ... }` / `elements { ... }`. Never a stored `XCUIElement` field (`let button: XCUIElement = ...`) — that reintroduces the stale-element problem the framework exists to prevent.
2. **Action methods** — one per user intent (`addToCart()`, `proceedToCheckout()`), calling `.tap()`/`.typeText()` on the screen's own elements. A method that spans multiple screens (navigates away) is fine — the screen doesn't need to "own" the destination.

## What does NOT belong in a Screen

- Assertions (`XCTAssert*`, `ScreenAssertions.assertThat`) — those live in the Spec.
- `sleep()`/`Thread.sleep` — use `Waits`/`ScreenElement`'s built-in waiting, or `dismissKeyboardIfPresent()` for the specific keyboard-covers-button case (see below).
- Hardcoded bundle identifiers or app paths — that's `TestEnvironment`'s job.

## A real, verified example (`Examples/MyDemoApp/Screens/LoginScreen.swift`)

```swift
public final class LoginScreen: Screen {
    public var usernameField: ScreenElement { element { self.app.textFields.element(boundBy: 0) } }
    public var passwordField: ScreenElement { element { self.app.secureTextFields.element(boundBy: 0) } }
    public var loginButton: ScreenElement { element { self.app.buttons["Login"] } }

    public func quickLogin(as user: QuickLoginUser = .bob) {
        app.buttons[user.buttonLabel].tap()
        loginButton.tap()
    }

    public func login(username: String, password: String) {
        usernameField.typeText(username)
        passwordField.typeText(password)
    }
}
```

## The keyboard-covers-button gotcha — and its real limits

`Screen.dismissKeyboardIfPresent()` attempts to swipe the on-screen keyboard down. **This is not a universal fix** — on iPhone, a software keyboard has no user-facing dismiss gesture at all (the "swipe to undock" gesture is iPad-only), so this only helps for apps that implement their own `UIScrollView` interactive-dismiss keyboard handling. Verified live against `saucelabs/my-demo-app-ios`: nine different dismissal techniques (swipe, return key, tap elsewhere, Escape key, background/foreground, a forced raw coordinate tap, a long drag, hardware-keyboard passthrough, a taller device) were all tried against its Login button and **none worked** — see `.claude/skills/app-notes` for the full account. If a new form's submit button silently does nothing after typing, don't assume `dismissKeyboardIfPresent()` will fix it — verify live whether the button's frame is actually covered (`element.isHittable` goes `false`) and whether anything dismisses the keyboard at all before building a Screen method around the assumption that it can be tapped after typing.

When a form has no working dismiss path, look for what `LoginScreen.quickLogin` uses: an app-provided shortcut that fills fields without ever focusing them (no keyboard, no problem). When no such shortcut exists (as for this app's Shipping/Payment forms), the honest move is a Screen method that only fills what's reliably fillable, and a Spec that documents the rest as blocked via `XCTSkip` with a clear reason — never silently skip the coverage or, worse, weaken the assertion to make it look passing.

## New Screens

Follow the same shape: a screen container getter when the app assigns one an identifier, element getters for everything the Specs need, action methods for each user-facing operation. See `.claude/skills/locators-assertions` for locator priority and `.claude/skills/app-notes` for what's already verified about the bundled demo app.
