# xcuitest-agentic Constitution

This is the authoritative rulebook for working in this repo. It's auto-loaded
every session. Each rule below points at the skill that goes deeper — read
that skill before acting on the rule, don't just take the one-liner on faith.

## 0. The framework is deterministic. Full stop.

`Sources/`, `HostRunner/`, and `Examples/` make **zero** LLM/API calls at
build or test time. `xcodebuild test` never talks to Claude, an MCP server,
or any network AI endpoint. Every "agentic" capability — planning,
generating, healing, maintaining — lives in `.claude/` and only runs during
a Claude Code dev-time session. If you're about to add a network call, an
API key, or an SDK import to anything under `Sources/`, `HostRunner/`, or
`Examples/`, stop — that does not belong there.

## 1. Screens never cache elements

A `Screen` subclass exposes only computed properties returning
`ScreenElement`/`ScreenElementList`, never a stored `XCUIElement`. Every
access re-resolves against the live UI tree. See
`.claude/skills/screen-object-conventions`.

## 2. Locator priority: accessibility identifier first

Order: `accessibilityIdentifier` → visible `label`/text → `NSPredicate` →
coordinate-based tap (banned without an inline justification comment citing
why no identifier/label was available). See
`.claude/skills/locators-assertions`.

## 3. One wait primitive

Nothing calls `sleep()` or `Thread.sleep`. All waiting goes through
`Waits`/`ScreenElement`/`ScreenAssertions`. See
`.claude/skills/locators-assertions`.

## 4. Assertions live in Specs, not Screens

`XCTAssert*` and `ScreenAssertions.assertThat` appear only in
`Examples/*/Specs/`. A Screen returns elements and performs actions; it never
asserts.

## 5. The app under test is a config concern

Bundle identifier, app path, device, and launch args come from
`config/*.json` via `TestEnvironment`/`AppUnderTest`. Nothing under
`Sources/` or `Examples/*/Screens` hardcodes a bundle identifier or app path.

## 6. Verify locators against the real app, never guess

The generator and healer drive the simulator live (via XcodeBuildMCP) or
read the app's actual source/storyboards before writing an identifier into a
Screen. An unverified identifier gets a `// TODO: verify` comment, never a
confident-looking guess. See `.claude/skills/app-notes` for what's already
been verified about the bundled My Demo App target.

## 7. Healing fixes the root cause, never the assertion

The healer patches the Screen file (or, for the rare structural case, the
Spec) — it never loosens an assertion, widens a timeout past
`Waits.defaultTimeout`, or adds a retry to force a flaky test green. If it
can't find a real fix, it leaves an `XCTSkip` with a comment explaining why,
not a silently-weakened test.

## 8. Entry points

- `/coverage <flow>` — plan and generate new tests for a flow
- `/heal [file | @tag]` — triage and fix failing tests
- `/maintain [what changed]` — full proactive maintenance pass

Drive these through the orchestrator (`.claude/agents/xcuitest-orchestrator.md`)
via the matching skill — don't hand-drive the leaf agents directly from a
plain conversation.
