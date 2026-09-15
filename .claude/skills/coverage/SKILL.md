---
name: coverage
description: /coverage <flow description> — add test coverage for a named app flow by delegating plan -> generate -> run to xcuitest-orchestrator.
---

# /coverage

Usage: `/coverage <flow description>`, e.g. `/coverage guest checkout with a saved card` or `/coverage product search and filtering`.

Call the `xcuitest-orchestrator` subagent with the flow description, telling it to run its coverage path (plan → generate → run, triaging/looping once on any failures the generator's own run leaves). Relay its final report back to the user: plan file written, Screen/Spec files created, test results, and anything left as `XCTSkip`.

Do not call `xcuitest-test-planner` or `xcuitest-test-generator` directly from this skill — always go through the orchestrator so triage/routing stays centralized.
