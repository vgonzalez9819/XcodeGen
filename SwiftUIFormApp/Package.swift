// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftUIFormApp",
    platforms: [
        .iOS(.v14),
        .macCatalyst(.v14)
    ],
    products: [
        .executable(name: "SwiftUIFormApp", targets: ["SwiftUIFormAppApp"])
    ],
    targets: [
        .target(
            name: "SwiftUIFormApp",
            path: "Sources/SwiftUIFormApp/Core"
        ),
        .executableTarget(
            name: "SwiftUIFormAppApp",
            dependencies: ["SwiftUIFormApp"],
            path: "Sources/SwiftUIFormApp/App"
        )
    ]
)
