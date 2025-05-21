// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftUIFormApp",
    platforms: [
        .iOS(.v14),
        .macCatalyst(.v14),
        // specify macOS 10.15+ so Combine and SwiftUI APIs are available when
        // compiling on macOS directly
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "SwiftUIFormApp", targets: ["SwiftUIFormApp"])
    ],
    targets: [
        .executableTarget(
            name: "SwiftUIFormApp",
            path: "Sources/SwiftUIFormApp"
        ),
        .testTarget(
            name: "SwiftUIFormAppTests",
            dependencies: ["SwiftUIFormApp"],
            path: "Tests/SwiftUIFormAppTests"
        )
    ]
)
