import Foundation

/// Describes which app the framework should drive: bundle identifier, where to
/// find the built `.app` (for CI install steps), and launch overrides. Every
/// field here is a config concern — never hardcoded in a Screen or Spec — so
/// pointing the framework at a different app under test is a config change,
/// not a code change.
public struct AppTargetConfig: Codable, Equatable {
    public var bundleIdentifier: String
    public var appPath: String?
    public var deviceName: String?
    public var platformVersion: String?
    public var launchArguments: [String]
    public var launchEnvironment: [String: String]

    public init(
        bundleIdentifier: String,
        appPath: String? = nil,
        deviceName: String? = nil,
        platformVersion: String? = nil,
        launchArguments: [String] = [],
        launchEnvironment: [String: String] = [:]
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.appPath = appPath
        self.deviceName = deviceName
        self.platformVersion = platformVersion
        self.launchArguments = launchArguments
        self.launchEnvironment = launchEnvironment
    }
}

/// Layered config resolution: `config/<name>.json` (selected via `TEST_ENV`,
/// default `local`) with `XCUITEST_AGENTIC_OVERRIDE_*` environment variables
/// applied on top. The config directory itself is passed in by the Xcode
/// scheme as `XCUITEST_AGENTIC_CONFIG_DIR` (e.g. `$(SRCROOT)/config`) since
/// the test bundle has no other reliable way to find the repo root.
public enum TestEnvironment {
    public static var name: String {
        ProcessInfo.processInfo.environment["TEST_ENV"] ?? "local"
    }

    public static func load(name: String = TestEnvironment.name) -> AppTargetConfig {
        let env = ProcessInfo.processInfo.environment
        guard let configDir = env["XCUITEST_AGENTIC_CONFIG_DIR"] else {
            preconditionFailure(
                "XCUITEST_AGENTIC_CONFIG_DIR is not set. Add it to the test target's scheme " +
                "environment variables, pointing at the repo's config/ directory " +
                "(e.g. $(SRCROOT)/config)."
            )
        }
        let path = "\(configDir)/\(name).json"
        guard let data = FileManager.default.contents(atPath: path) else {
            preconditionFailure("Could not read \(path). Does config/\(name).json exist?")
        }
        var config: AppTargetConfig
        do {
            config = try JSONDecoder().decode(AppTargetConfig.self, from: data)
        } catch {
            preconditionFailure("Failed to decode \(path): \(error)")
        }
        if let bundleID = env["XCUITEST_AGENTIC_OVERRIDE_BUNDLE_ID"] {
            config.bundleIdentifier = bundleID
        }
        if let appPath = env["XCUITEST_AGENTIC_OVERRIDE_APP_PATH"] {
            config.appPath = appPath
        }
        return config
    }
}
