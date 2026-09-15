---
name: locators-assertions
description: Locator priority order, the one wait primitive, and how ScreenAssertions works.
---

# Locators and assertions

## Locator priority (Constitution rule 2)

1. `accessibilityIdentifier` — `app.buttons["Catalog-tab-item"]`, `app.otherElements.matching(identifier: "ProductItem")`. Always prefer this when the app sets one — verify it live or in the app's own storyboard/source, never guess a plausible-looking string.
2. Visible `label`/text — `app.buttons["Login"]`, `app.staticTexts[productName]`. Valid when there's no identifier and the label is a real, stable piece of UI text (a button title, not something localized/dynamic that changes per test data).
3. `NSPredicate` / structural query — e.g. `app.otherElements["Screen"].textFields.element(boundBy: n)` when a form's fields carry no identifier or label of their own. **Requires a code comment** explaining why (which fields, what order, how it was verified) — see `ShippingAddressScreen`/`PaymentScreen` for the pattern: scope the query to the screen's own container so it can't accidentally match a field on another screen, and document how the index order was confirmed (declaration order that turned out to match visual order, verified via a live accessibility snapshot).
4. Coordinate-based tap (`.coordinate(withNormalizedOffset:)`) — last resort, banned by the `enforce_constitution.py` hook unless preceded by a `// justified: ...` comment.

## The one wait primitive

`Waits.until` / `Waits.expectExistence` (in `XCUITestAgenticCore`) are what `ScreenElement` and `ScreenAssertions` are built on. Nothing calls `sleep()` or `Thread.sleep` — the hook blocks it. If something needs a genuinely different timeout than the 10s default, pass `timeout:` explicitly rather than reaching for a sleep.

## Assertions

`ScreenAssertions.assertThat(element)` returns a fluent, polling assertion (`isVisible()`, `isNotVisible()`, `hasLabel(_:)`), always in a Spec, never in a Screen. Prefer it over ad hoc `XCTAssertTrue(element.waitForExistence(...))` — the one exception is asserting on something that isn't a `ScreenElement` at all (e.g. `app.alerts.staticTexts["..."]` for a one-off system alert check), where a direct `XCTAssertTrue(...waitForExistence...)` is fine.

## The keyboard-covers-button gotcha

See `.claude/skills/screen-object-conventions` and `.claude/skills/app-notes`. This is an interaction concern, not a locator problem — the element is found correctly (`.exists` is true), but `.isHittable` goes false and a `.tap()` silently does nothing because the keyboard window sits on top. `Screen.dismissKeyboardIfPresent()` is worth trying but is not guaranteed to work (iPhone keyboards have no universal dismiss gesture) — confirm live rather than assuming it fixed things.
