# Codable Request

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift 4.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="https://github.com/iamjono/codableRequest/blob/master/LICENSE" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/iamjono" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@iamjono-blue.svg?style=flat" alt="Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

Server Side Swift library that executes an HTTP Request and returns the data formatted in the supplied Codable object type.

This library leverages the [Perfect HTTP](https://github.com/PerfectlySoft/Perfect-HTTP) and [CURL](https://github.com/PerfectlySoft/Perfect-CURL) libraries.

## Installation

Add the following to your Package.swift file's dependencies array:

``` swift
.package(url: "https://github.com/iamjono/codableRequest.git", "1.0.0"..<"2.0.0")
```

Then make sure you have executed a `swift package update` and regenerate your Xcode project file.

## Usage

You must have a struct that conforms to the `Codable` protocol matching the response you are expecting. In the examples used in the tests, the result is transformed into the `HTTPbin` struct type as shown below. An optional error type can be specified to contain a customized error format.

The full form of this request is:

``` swift
try CodableRequest.request<T: Codable, E: ErrorResponseProtocol>(
		_ method: HTTPMethod,
		_ url: String,
		to: T.Type,
		error: E.Type,
		params: [String: Any] = [String: Any](),
		encoding: String = "json",
		bearerToken: String = ""
		)
```

- The `method` and `url` are unnamed parameters. 
- The `to` and `error` parameters are the types into which to attempt the encode/decode process.
- `params` is the name/value dictionary that is transformed into the form param or json object submitted along with a POST or PATCH request.
- `encoding` will determine if the request is formatted as JSON or Form.
- `bearerToken`, if populated, will submit an Authorization header with this bearer token.

### To execute a GET request, and transform into an object

``` swift
let response : HTTPbin = try CodableRequest.request(
	.get, 
	"https://httpbin.org/get", 
	to: HTTPbin.self, 
	error: ErrorResponse.self
	)
```

The result of this request will be an object of type `HTTPbin`.

### To submit a POST request as a Form

``` swift
let response : HTTPbin = try CodableRequest.request(
	.post, 
	"https://httpbin.org/post", 
	to: HTTPbin.self, 
	error: ErrorResponse.self, 
	params: ["donkey":"kong"], 
	encoding: "form"
	)
```

### To submit a POST request as JSON

``` swift
let response : HTTPbin = try CodableRequest.request(
	.post, 
	"https://httpbin.org/post", 
	to: HTTPbin.self, 
	error: ErrorResponse.self, 
	params: ["donkey":"kong"], 
	encoding: "json"
	)
```

## Handling errors

``` swift
do {
	let _ : HTTPbin = try CodableRequest.request(
		.post, 
		"https://httpbin.org/get", 
		to: HTTPbin.self, 
		error: ErrorResponse.self
		)
} catch let error as ErrorResponse {
	print(error.error?.code) // 405
} catch {
	print(error)
}
```

This request will return a 405, an unsupported request type.

The following error object has been populated as a response:

``` swift
ErrorResponse(
	error: Optional(codableRequest.ErrorMsg(
		message: Optional("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">\n<title>405 Method Not Allowed</title>\n<h1>Method Not Allowed</h1>\n<p>The method is not allowed for the requested URL.</p>\n"), 
		type: Optional(""), 
		param: Optional(""), 
		code: Optional("405"))
	)
)

```

## Codable structs used in these examples

The following structs are used by the tests, and the above examples.

``` swift
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
```

## Contributing

This library is a work in progress. It is initially being developed in response to a need for the [Stripe API](https://github.com/iamjono/Perfect-Stripe) under development. 

Pull requests are welcome, and if you wish to chat about how to use or how to improve, please hit me up on the [Perfect Slack channel](https://www.perfect.ly) - my handle is "iamjono".

Thank you to [Fatih Nayebi](https://github.com/conqueror) for inspiration and assistance.