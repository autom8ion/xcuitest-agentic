// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "XCUITestAgentic",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "XCUITestAgenticCore", targets: ["XCUITestAgenticCore"]),
        .library(name: "ScreenObject", targets: ["ScreenObject"]),
        .library(name: "ScreenAssertions", targets: ["ScreenAssertions"])
    ],
    targets: [
        .target(
            name: "XCUITestAgenticCore"
        ),
        .target(
            name: "ScreenObject",
            dependencies: ["XCUITestAgenticCore"]
        ),
        .target(
            name: "ScreenAssertions",
            dependencies: ["XCUITestAgenticCore", "ScreenObject"]
        )
    ]
)
