---
name: heal
description: /heal [file | @tag] — fix failing xcuitest-agentic tests by delegating triage -> heal/stabilize to xcuitest-orchestrator.
---

# /heal

Usage: `/heal` (whole example suite), `/heal Examples/MyDemoApp/Specs/CheckoutFlowTests.swift`, or `/heal <test name>`.

Call the `xcuitest-orchestrator` subagent with the scope, telling it to run its heal path: get a concrete failing-test list, triage each, and route to the healer (stale locator / UI change) or flaky-stabilizer (flaky) — never the whole suite blind, and never a forced-green fix.

Relay the orchestrator's final report: what was healed, what's still broken and why (product regression / env issue / unresolved after retries), and any files a human should look at.
