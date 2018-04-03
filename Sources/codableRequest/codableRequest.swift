//
//  CodableRequest.swift
//  CodableRequest
//
//  Created by Jonathan Guthrie on 2018-04-02.
//
//


import Foundation
import PerfectLib
import PerfectCURL
import cURL
import PerfectHTTP

protocol ErrorResponseProtocol: Codable, Error {}

public struct ErrorResponse: ErrorResponseProtocol {
	public var error: ErrorMsg?
}
public struct ErrorMsg: Codable {
	public var message: String?
	public var type: String?
	public var param: String?
	public var code: String?
}

public struct CodableRequest {
	/// The function that triggers the specific interaction with a remote server
	/// Parameters:
	/// - method: The HTTP Method enum, i.e. .get, .post
	/// - route: The route required
	/// - to: The type of the object to parse into
	/// - error: The error type into which to parse the error
	/// - params: The name/value pair to transform into the JSON or form submission
	/// - encoding: json, or form
	/// - bearerToken: A string with the authentication token
	/// Response: CURLResponse
	/// Usage:
	/// let r : HTTPbin = try CodableRequest.request(.post, "https://httpbin.org/get", to: HTTPbin.self, error: ErrorResponse.self)

	static func request<T: Codable, E: ErrorResponseProtocol>(
		_ method: HTTPMethod,
		_ url: String,
		to responseType: T.Type,
		error errorType: E.Type,
		params: [String: Any] = [String: Any](),
		encoding: String = "json",
		bearerToken: String = "") throws -> T {

		var curlObject = CURLRequest(url, options: [CURLRequest.Option.httpMethod(method)])
		if !params.isEmpty, encoding == "json" {
			var byteArray = [UInt8]()
			do {
				byteArray = [UInt8](try params.jsonEncodedString().utf8)
			} catch {
				throw error
			}
			curlObject = CURLRequest(url, CURLRequest.Option.httpMethod(method), .postData(byteArray))
		} else if !params.isEmpty {
			var byteArray = [UInt8]()
			byteArray = [UInt8]((self.toParams(params).joined(separator: "&")).utf8)
			curlObject = CURLRequest(url, CURLRequest.Option.httpMethod(method), .postData(byteArray))
		}

		curlObject.addHeader(.accept, value: "application/json")
		curlObject.addHeader(.cacheControl, value: "no-cache")
		curlObject.addHeader(.userAgent, value: "PerfectCodableRequest1.0")

		if !bearerToken.isEmpty {
			curlObject.addHeader(.authorization, value: "Bearer \(bearerToken)")
		}

		if encoding == "json" {
			curlObject.addHeader(.contentType, value: "application/json")
		} else {
			curlObject.addHeader(.contentType, value: "application/x-www-form-urlencoded")
		}

		do {
			let response = try curlObject.perform()
			// For debug:
//			print("response.responseCode:")
//			print(response.responseCode)
//			print(response.url)
//			print(response.bodyString)

			if response.responseCode > 400 {
				do {
					let e = try response.bodyJSON(errorType)
					throw e

				} catch {
					let e = ErrorResponse(error: ErrorMsg(message: response.bodyString, type: "", param: "", code: "\(response.responseCode)"))
					throw e
				}
			}
			let model = try response.bodyJSON(responseType)
			return model as T

		} catch let error as CURLResponse.Error {
			let e = try error.response.bodyJSON(errorType)
			throw e

		} catch {
			throw error
		}
	}


	private static func toParams(_ params:[String: Any]) -> [String] {
		var str = [String]()
		for (key, value) in params {
			let v = "\(value)".stringByEncodingURL
			str.append("\(key)=\(v)")
		}
		return str
	}
}
