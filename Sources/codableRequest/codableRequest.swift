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

public protocol ErrorResponseProtocol: Codable, Error {}

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
	
	public static func request<T: Codable, E: ErrorResponseProtocol>(
		_ method: HTTPMethod,
		_ url: String,
		to responseType: T.Type,
		error errorType: E.Type,
		body: String = "",
		json: [String: Any] = [String: Any](),
		params: [String: Any] = [String: Any](),
		encoding: String = "json",
		bearerToken: String = "",
		headers: [String: String]? = nil) throws -> T {
		
		var curlObject = CURLRequest(url, options: [CURLRequest.Option.httpMethod(method)])
		var byteArray = [UInt8]()
		
		if !body.isEmpty {
			print(body.utf8)
			byteArray = [UInt8](body.utf8)
		} else if !json.isEmpty {
			do {
				print(try json.jsonEncodedString().utf8)
				byteArray = [UInt8](try json.jsonEncodedString().utf8)
			} catch {
				throw error
			}
		} else if !params.isEmpty {
			byteArray = [UInt8]((self.toParams(params).joined(separator: "&")).utf8)
		}
		
		
		if method == .post || method == .put || method == .patch {
			curlObject = CURLRequest(url, CURLRequest.Option.httpMethod(method), .postData(byteArray))
		} else {
			curlObject = CURLRequest(url, CURLRequest.Option.httpMethod(method))
		}
		
		curlObject.addHeader(.accept, value: "application/json")
		curlObject.addHeader(.cacheControl, value: "no-cache")
		curlObject.addHeader(.userAgent, value: "PerfectCodableRequest1.0")
		
		if let customHeaders = headers {
			for (key, value) in customHeaders {
				curlObject.addHeader(.custom(name: key), value: value)
			}
		}
		
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
			
			if response.responseCode >= 400 {
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
