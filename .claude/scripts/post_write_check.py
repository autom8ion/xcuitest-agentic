#!/usr/bin/env python3
"""PostToolUse hook for Write/Edit/MultiEdit on Swift files under Sources/.

Runs `swift build` and feeds any compiler errors back in the same turn,
rather than letting a broken framework file surface later in an unrelated
xcodebuild run. Scoped to Sources/ (the SPM package) since that's what
`swift build` covers; changes under Examples/ or HostRunner/ need an
xcodebuild invocation instead (agents run that themselves via Bash when
relevant — this hook only guards the always-cheap case).

Protocol: reads the PostToolUse JSON payload on stdin. Prints diagnostic
text to stderr and exits 2 to surface it back to the agent; exits 0
otherwise.
"""
import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]


def main() -> None:
    payload = json.load(sys.stdin)
    tool_input = payload.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not file_path.endswith(".swift") or "/Sources/" not in file_path:
        sys.exit(0)

    result = subprocess.run(
        ["swift", "build"],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        timeout=180,
    )
    if result.returncode != 0:
        sys.stderr.write("swift build failed after editing " + file_path + ":\n")
        sys.stderr.write(result.stderr[-4000:])
        sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
