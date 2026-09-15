#!/usr/bin/env python3
"""PreToolUse hook for Write/Edit/MultiEdit.

Mechanically enforces the parts of CLAUDE.md that are cheap to check with a
regex, so a violation is caught in the same turn it's introduced rather than
at review. This is a blunt instrument on purpose — it exists to catch
obvious anti-patterns (sleep(), cached XCUIElement fields, an unexplained
coordinate tap, an assertion inside a Screen file), not to replace judgment.
A rule it doesn't catch is still a rule.

Protocol: reads the PreToolUse JSON payload on stdin. To block, prints a
JSON object {"decision": "block", "reason": "..."} on stdout and exits 0.
To allow, exits 0 with no output.
"""
import json
import re
import sys

BANNED_PATTERNS = [
    (r"\bsleep\(", "sleep() is banned — wait via Waits/ScreenElement/ScreenAssertions (Constitution rule 3)."),
    (r"Thread\.sleep", "Thread.sleep is banned — wait via Waits/ScreenElement/ScreenAssertions (Constitution rule 3)."),
]

CACHED_ELEMENT_PATTERN = re.compile(r"\b(let|var)\s+\w+\s*:\s*XCUIElement\b\s*=")

COORDINATE_TAP_PATTERN = re.compile(r"\.coordinate\(")

SCREEN_FILE_PATTERN = re.compile(r"/Screens/[^/]+\.swift$")
ASSERT_PATTERN = re.compile(r"\bXCTAssert\w*\(|ScreenAssertions\.assertThat\(")


def check(file_path: str, content: str) -> list[str]:
    violations = []

    if not file_path.endswith(".swift"):
        return violations

    for pattern, message in BANNED_PATTERNS:
        if re.search(pattern, content):
            violations.append(message)

    if CACHED_ELEMENT_PATTERN.search(content) and "/Screens/" in file_path:
        violations.append(
            "A Screen stores a resolved XCUIElement in a field — this reintroduces the "
            "stale-element problem ScreenElement exists to prevent (Constitution rule 1). "
            "Expose it as a computed property returning ScreenElement instead."
        )

    for match in COORDINATE_TAP_PATTERN.finditer(content):
        line_start = content.rfind("\n", 0, match.start()) + 1
        line_end = content.find("\n", match.start())
        line = content[line_start: line_end if line_end != -1 else None]
        if "justified:" not in line and "// justified" not in content[max(0, match.start() - 200):match.start()]:
            violations.append(
                "Coordinate-based tap (.coordinate(...)) found without a preceding "
                "'// justified: ...' comment explaining why no identifier/label locator "
                "works (Constitution rule 2)."
            )
            break

    if SCREEN_FILE_PATTERN.search(file_path) and ASSERT_PATTERN.search(content):
        violations.append(
            "Assertion found inside a Screens/ file — assertions belong in Specs via "
            "ScreenAssertions, never inline in a Screen (Constitution rule 4)."
        )

    return violations


def main() -> None:
    payload = json.load(sys.stdin)
    tool_input = payload.get("tool_input", {})
    file_path = tool_input.get("file_path", "")
    content = tool_input.get("content") or tool_input.get("new_string") or ""

    violations = check(file_path, content)
    if violations:
        print(json.dumps({
            "decision": "block",
            "reason": "Constitution violation(s):\n- " + "\n- ".join(violations),
        }))
    sys.exit(0)


if __name__ == "__main__":
    main()
