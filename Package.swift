// swift-tools-version:4.0
// Generated automatically by Perfect Assistant 2
// Date: 2018-04-02 20:56:12 +0000
import PackageDescription

let package = Package(
	name: "codableRequest",
	products: [
		.library(name: "codableRequest", targets: ["codableRequest"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "codableRequest", dependencies: ["PerfectCURL","PerfectHTTP"]),
		.testTarget(name: "codableRequestTests", dependencies: ["codableRequest"])
	]
)
