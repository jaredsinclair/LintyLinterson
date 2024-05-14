// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "LintyLinterson",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .plugin(
            name: "SwiftLint",
            targets: [
                "SwiftLint"
            ]
        ),
        .plugin(
            name: "SwiftGen",
            targets: [
                "SwiftGen"
            ]
        ),
        .plugin(
            name: "Header Copyright",
            targets: [
                "Header Copyright"
            ]
        )
    ],
    targets: [
        .binaryTarget(
            name: "swiftformat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.51.12/swiftformat.artifactbundle.zip",
            checksum: "0310600634dda94aeaae6cf305daa6cf2612712dd5760b0791b182db98d0521e"
        ),
        .binaryTarget(
            name: "swiftgen",
            url: "https://github.com/SwiftGen/SwiftGen/releases/download/6.6.2/swiftgen-6.6.2.artifactbundle.zip",
            checksum: "7586363e24edcf18c2da3ef90f379e9559c1453f48ef5e8fbc0b818fbbc3a045"
        ),
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.54.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "963121d6babf2bf5fd66a21ac9297e86d855cbc9d28322790646b88dceca00f1"
        ),
        .plugin(
            name: "Header Copyright",
            capability: .command(
                intent: .sourceCodeFormatting(),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "This plugin applies the standard copyright header to all Swift files."
                    )
                ]
            ),
            dependencies: [
                "swiftformat",
            ]
        ),
        .plugin(
            name: "SwiftGen",
            capability: .buildTool(),
            dependencies: [
                "swiftgen"
            ]
        ),
        .plugin(
            name: "SwiftLint",
            capability: .buildTool(),
            dependencies: [
                "SwiftLintBinary"
            ]
        )
    ]
)
