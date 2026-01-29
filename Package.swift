// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ParadigmAudioHub",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ParadigmAudioHub", targets: ["ParadigmAudioHub"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ParadigmAudioHub",
            path: "Sources/ParadigmAudioHub",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
