# xcuitest-agentic

An agentic XCUITest framework for iOS: a deterministic Swift/XCUITest core built on the Screen Object pattern, plus a Claude Code-driven layer (`.claude/`) that plans, generates, heals, and maintains tests — but never runs inside the test framework itself. `xcodebuild test` never talks to an LLM; every agentic capability is a dev-time-only Claude Code session.

This mirrors the house pattern of the sibling `-agentic` frameworks (`playwright-agentic`, `appium-agentic`): deterministic core, agentic layer entirely in `.claude/`.

## Layout

```
Sources/                   SPM package — the reusable, app-agnostic framework
  XCUITestAgenticCore/      config (TestEnvironment/AppTargetConfig), Waits, AppUnderTest
  ScreenObject/             Screen, ScreenElement (re-resolving), ScreenElementList, ScreenFactory
  ScreenAssertions/         fluent polling assertions

HostRunner/                 xcodegen project spec (project.yml) + generated Xcode project
  Host/                      a deliberately blank host app — never itself under test
                             (the UI test target drives the app-under-test by bundle ID)

Examples/MyDemoApp/         a real, working example integration
  Screens/                   Login, Catalog, ProductDetails, Cart, MoreMenu, ShippingAddress,
                              Payment, ReviewOrder, CheckoutComplete, About, GeoLocation,
                              Drawing, Webview, QrCodeScanner
  Specs/                     XCTestCase specs: login, catalog browsing/sorting, product detail
                              interactions (quantity/color/rating), cart management (add/remove/
                              quantity), the More menu's sub-screens and Reset App State, and
                              full checkout

config/                     local.json / ci.json — which app to drive, device, launch args
scripts/setup-demo-app.sh   fetches + builds the bundled demo app (gitignored, never committed)

.claude/                    the agentic layer — see below
```

## Quickstart

Requires Xcode with an iOS Simulator runtime installed, and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```bash
# 1. Fetch and build the bundled demo app (Sauce Labs' My Demo App iOS),
#    install it on a simulator. Safe to re-run.
./scripts/setup-demo-app.sh

# 2. Generate the host Xcode project from HostRunner/project.yml
cd HostRunner && xcodegen generate && cd ..

# 3. Run the example suite
xcodebuild test \
  -project HostRunner/XCUITestAgenticHost.xcodeproj \
  -scheme XCUITestAgenticUITests \
  -destination "platform=iOS Simulator,name=iPhone 16"
```

`swift build` alone builds and typechecks the framework package (`Sources/`) without needing Xcode/a simulator — useful for a fast inner loop on framework changes.

## Why a thin host app driving an external bundle ID

XCUITest needs a UI test target attached to some app scheme to run at all, but `XCUIApplication(bundleIdentifier:)` lets that test target drive **any** installed app on the simulator, not just its own host. So `HostRunner/Host` is a permanent, nearly-empty app, and which app actually gets tested is a `config/*.json` concern (`bundleIdentifier`, `appPath`, `deviceName`, `launchArguments`). Pointing this framework at a different app is:

1. Point `config/local.json` (and `ci.json`) at the new app's bundle identifier / build output.
2. Add `Examples/<YourApp>/Screens/` and `Examples/<YourApp>/Specs/` following the conventions in `.claude/skills/screen-object-conventions`.
3. Nothing under `Sources/` or `HostRunner/` needs to change.

## The agentic layer

Entirely in `.claude/` — skills, subagents, and hooks that only run during a Claude Code session:

- **`/coverage <flow>`** — plans (live simulator exploration via [XcodeBuildMCP](https://www.xcodebuildmcp.com/)) and generates real Screen + Spec files for a new flow.
- **`/heal [file | @tag]`** — triages failing tests (stale locator / UI change / product regression / flaky / env issue) and routes to a healer or flaky-stabilizer that fixes the root cause and reruns — never a forced-green fix.
- **`/maintain [what changed]`** — a full proactive sweep: status, heal, optional coverage, and audits for dead specs / orphaned locators / chronic skips.

See `CLAUDE.md` for the full rulebook (locator priority, the one wait primitive, why assertions never live in a Screen) and `.claude/skills/app-notes` for what's already verified about the bundled demo app — including a real, thoroughly-verified app defect worth reading before writing a new form flow: the demo app's Login button (and most of its Shipping form) sit under the on-screen keyboard once a field is focused, the app has no dismiss mechanism of any kind, and nine different dismissal techniques were confirmed live to fail. `Screen.dismissKeyboardIfPresent()` exists for apps that *do* support interactive dismiss — it doesn't help this one.

## A note on the bundled example

`Examples/MyDemoApp` targets [`saucelabs/my-demo-app-ios`](https://github.com/saucelabs/my-demo-app-ios), the same demo shopping app already used by the sibling `appium-agentic` framework. Every locator in `Examples/MyDemoApp/Screens` was verified against that app's actual storyboards/source or a live simulator run — none were guessed.

The example suite is honest about what it found: login, guest browsing, cart, and reaching the Shipping form are fully verified and green. Full checkout (city/state/zip/country onward, and everything past Shipping) is verified as far as it can go and then documents a real, confirmed app defect via `XCTSkip` rather than faking a pass — see `.claude/skills/app-notes` for the full investigation, including the nine dismissal techniques that were tried and why the app's own quick-login buttons are the one thing that does work around it for authentication.
