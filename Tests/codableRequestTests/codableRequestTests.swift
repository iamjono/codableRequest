import XCTest
@testable import codableRequest

// Using resttesttest.com & httpbin.org for testing

struct HTTPbin: Codable {
	var args: [String: String]?
	var data: String?
	var files: [String: String]?
	var form: [String: String]?
	var headers: HTTPbinHeaders?
	var json: [String: String]?
	var origin: String?
	var url: String?
}

struct HTTPbinHeaders: Codable {
	var accept: String?
	var acceptEncoding: String?
	var acceptLanguage: String?
	var connection: String?
	var contentType: String?
	var dnt: String?
	var host: String?
	var origin: String?
	var referer: String?
	var userAgent: String?

	enum CodingKeys : String, CodingKey {
		case accept = "Accept"
		case acceptEncoding = "Accept-Encoding"
		case acceptLanguage = "Accept-Language"
		case connection = "Connection"
		case contentType = "Content-Type"
		case dnt = "Dnt"
		case host = "Host"
		case origin = "Origin"
		case referer = "Referer"
		case userAgent = "User-Agent"
	}

}

final class codableRequestTests: XCTestCase {
	func testPostErrorHandling() {
		do {
			let _ : HTTPbin = try CodableRequest.request(.post, "https://httpbin.org/get", to: HTTPbin.self, error: ErrorResponse.self)
			XCTFail()
		} catch let error as ErrorResponse {
			// Pass
			XCTAssert(error.error?.code == "405", "Response should have been 405 Method not allowed")
		} catch {
			XCTFail("Should have had a graceful error handling")
		}
	}

	func testGet() {
		do {
			let response : HTTPbin = try CodableRequest.request(.get, "https://httpbin.org/get", to: HTTPbin.self, error: ErrorResponse.self)
			XCTAssert(response.url == "https://httpbin.org/get", "Unexpected response")
		} catch {
			XCTFail("\(error)")
		}
	}

	func testPostEmpty() {
		do {
			let response : HTTPbin = try CodableRequest.request(.post, "https://httpbin.org/post", to: HTTPbin.self, error: ErrorResponse.self)
			XCTAssert(response.url == "https://httpbin.org/post", "Unexpected response")
		} catch {
			XCTFail("\(error)")
		}
	}

	func testPostForm() {
		do {
			let response : HTTPbin = try CodableRequest.request(.post, "https://httpbin.org/post", to: HTTPbin.self, error: ErrorResponse.self, params: ["donkey":"kong"], encoding: "form")
			XCTAssert(response.url == "https://httpbin.org/post", "Unexpected response")
			XCTAssert(response.form == ["donkey":"kong"], "Unexpected response ([donkey:kong])")
		} catch {
			XCTFail("\(error)")
		}
	}

	func testPostJSON() {
		do {
			let outbound: [String: Any] = ["Hello": "World!", "Thing1": 2]
			let response : HTTPbin = try CodableRequest.request(.post, "https://httpbin.org/post", to: HTTPbin.self, error: ErrorResponse.self, params: outbound)
			XCTAssert(response.url == "https://httpbin.org/post", "Unexpected response")
			print(response)
//			XCTAssert(response.json == outbound, "Unexpected response (outbound)")
		} catch {
			XCTFail("\(error)")
		}
	}


    static var allTests = [
		("testPostErrorHandling", testPostErrorHandling),
		("testGet", testGet),
		("testPostEmpty", testPostEmpty),
		("testPostForm", testPostForm),
		("testPostJSON", testPostJSON),
    ]
}
