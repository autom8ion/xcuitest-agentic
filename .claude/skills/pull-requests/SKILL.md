---
name: pull-requests
description: Pre-PR checklist for xcuitest-agentic changes.
---

# Before opening or updating a PR

1. `swift build` passes (covers `Sources/`).
2. `xcodebuild build-for-testing` passes for `XCUITestAgenticUITests` against a current iOS Simulator runtime — a Screens/Specs-only change won't be caught by `swift build` alone.
3. Any touched Specs actually ran green (`xcodebuild test -only-testing:...`), not just compiled.
4. If you added or changed a locator, it's either identifier-based (verified against the app source or a live snapshot) or carries the justification comment the Constitution requires for a fallback locator.
5. If you touched `Examples/MyDemoApp/`, check whether `.claude/skills/app-notes` needs updating — it's the durable record other agents rely on; stale notes cost the next session real time.
6. `HostRunner/project.yml` changed but `HostRunner/*.xcodeproj` wasn't regenerated? Run `xcodegen generate` — the generated project isn't committed (see `.gitignore`), so this only matters for your own local run, but mention in the PR description if `project.yml` changed so reviewers know to regenerate.
