// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "easysketchcam",
    defaultLocalization: "es",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "EasySketchCam", type: .dynamic, targets: ["EasySketchCam"]),
    ],
    dependencies: [
        .package(url: "https://github.com/skiptools/skip.git", from: "1.9.7"),
        .package(url: "https://github.com/skiptools/skip-ui.git", from: "1.59.0"),
        .package(url: "https://github.com/skiptools/skip-kit.git", from: "1.1.3"),
    ],
    targets: [
        .target(name: "EasySketchCam", dependencies: [
            .product(name: "SkipUI", package: "skip-ui"),
            .product(name: "SkipKit", package: "skip-kit"),
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ],
    swiftLanguageModes: [.v5]
)

// Setting the SKIP_ZERO=1 environment will strip out the Skip plugin and all Skip dependencies
if Context.environment["SKIP_ZERO"] ?? "0" != "0" {
    package.targets.forEach { target in
        // remove the Skip plugin
        target.plugins?.removeAll(where: {
            if case .plugin(let name, _) = $0 {
                return name == "skipstone"
            } else {
                return false
            }
        })

        // remove the Skip target dependencies
        target.dependencies.removeAll(where: { dependency in
            if case .productItem(_, let package, _, _) = dependency {
                return package == "skip" || package?.hasPrefix("skip-") == true
            } else {
                return false
            }
        })
    }

    // remove the Skip package dependencies
    package.dependencies.removeAll(where: { dependency in
        if case .sourceControl(_, let url, _) = dependency.kind {
            return url.hasPrefix("https://github.com/skiptools/")
        } else {
            return false
        }
    })
}
