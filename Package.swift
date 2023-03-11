// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "PPMKit",
	platforms: [.macOS(.v10_12), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
	products: [
		.library(
			name: "PPMKit",
			targets: ["PPMKit"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "PPMKit",
			dependencies: []),
		.testTarget(
			name: "PPMKitTests",
			dependencies: ["PPMKit"],
			resources: [
				.process("resources"),
			]
		),
	]
)
