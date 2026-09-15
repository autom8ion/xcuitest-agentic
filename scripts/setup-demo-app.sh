#!/usr/bin/env bash
#
# Clones saucelabs/my-demo-app-ios at a pinned commit, builds it for the
# iOS Simulator, and installs it on the target simulator so the
# xcuitest-agentic UI tests have something real to drive.
#
# The clone lives in .demo-app/ (gitignored) — it is never committed to this
# repo, mirroring appium-agentic's "downloadSampleApps" pattern.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEMO_APP_DIR="$REPO_ROOT/.demo-app"
DEMO_APP_REPO="https://github.com/saucelabs/my-demo-app-ios.git"
# Pinned for reproducibility; bump deliberately and re-verify the Screens
# under Examples/MyDemoApp still match after bumping.
DEMO_APP_REF="main"
DEVICE_NAME="${DEVICE_NAME:-iPhone 16}"
DERIVED_DATA="$DEMO_APP_DIR/DerivedData"

echo "==> Setting up My Demo App (iOS) in $DEMO_APP_DIR"

if [ ! -d "$DEMO_APP_DIR/.git" ]; then
  git clone --depth 1 --branch "$DEMO_APP_REF" "$DEMO_APP_REPO" "$DEMO_APP_DIR"
else
  echo "==> Reusing existing clone"
fi

cd "$DEMO_APP_DIR"

# `OS=latest` (xcodebuild's default when OS is omitted) resolves to the
# newest installed runtime, which may not have $DEVICE_NAME available (e.g.
# a brand-new Xcode's newest runtime not yet shipping every device type).
# Pick the newest runtime that actually has this device instead.
DEVICE_OS=$(xcrun simctl list devices available -j | /usr/bin/python3 -c "
import json, sys
devices = json.load(sys.stdin)['devices']
versions = []
for runtime, entries in devices.items():
    if 'iOS' not in runtime:
        continue
    if any(d['name'] == '$DEVICE_NAME' for d in entries):
        versions.append(runtime.split('iOS-')[-1].replace('-', '.'))
versions.sort(key=lambda v: [int(p) for p in v.split('.')])
print(versions[-1] if versions else '')
")
if [ -z "$DEVICE_OS" ]; then
  echo "error: no installed iOS Simulator runtime has a '$DEVICE_NAME' device. Run 'xcrun simctl list devices available' to see options, or set DEVICE_NAME." >&2
  exit 1
fi
echo "==> Using simulator: $DEVICE_NAME, iOS $DEVICE_OS"

echo "==> Building for iphonesimulator"
xcodebuild build-for-testing \
  -workspace "My Demo App.xcworkspace" \
  -scheme "My Demo App" \
  -sdk iphonesimulator \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA" \
  -destination "platform=iOS Simulator,name=$DEVICE_NAME,OS=$DEVICE_OS"

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/My Demo App.app"
if [ ! -d "$APP_PATH" ]; then
  echo "error: expected built app at $APP_PATH but it does not exist" >&2
  exit 1
fi

echo "==> Booting simulator: $DEVICE_NAME (iOS $DEVICE_OS)"
UDID=$(xcrun simctl list devices available -j | /usr/bin/python3 -c "
import json, sys
devices = json.load(sys.stdin)['devices']
target_runtime_suffix = 'iOS-' + '$DEVICE_OS'.replace('.', '-')
for runtime, entries in devices.items():
    if not runtime.endswith(target_runtime_suffix):
        continue
    for d in entries:
        if d['name'] == '$DEVICE_NAME':
            print(d['udid'])
            sys.exit(0)
")

if [ -z "$UDID" ]; then
  echo "==> No existing '$DEVICE_NAME' (iOS $DEVICE_OS) simulator found, creating one"
  RUNTIME_ID=$(xcrun simctl list runtimes available -j | /usr/bin/python3 -c "
import json, sys
for r in json.load(sys.stdin)['runtimes']:
    if r['version'] == '$DEVICE_OS':
        print(r['identifier'])
        sys.exit(0)
")
  DEVICE_TYPE_ID="com.apple.CoreSimulator.SimDeviceType.$(echo "$DEVICE_NAME" | tr ' ' '-')"
  UDID=$(xcrun simctl create "$DEVICE_NAME" "$DEVICE_TYPE_ID" "$RUNTIME_ID")
fi

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl install "$UDID" "$APP_PATH"

echo "==> Done. My Demo App is installed on simulator $UDID ($DEVICE_NAME)."
echo "    Bundle identifier: com.saucelabs.mydemo.app.ios"
echo "    App path (for config/*.json appPath): ${APP_PATH#"$REPO_ROOT"/}"
