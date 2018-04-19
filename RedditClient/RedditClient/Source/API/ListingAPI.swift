//
//  ListingAPI.swift
//  RedditClient
//
//  Created by Yana VV on 4/18/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

class ListingAPI {

	@discardableResult
	static func topList(_ session: URLSession?, limit: Int = 25, count: Int, after: String?, before: String?, completion: ((APIResult<ThingList?>) -> Void)?) -> URLSessionDataTask? {

		let session = session ?? URLSession.shared

		let request = RequestFactory.requestForTopListing(count: count, limit: limit, after: after, before: before)
		let listingTask = session.dataTask(with: request) { (data, response, error) in
			let result = handleFinishedListingTask(data: data, response: response, error: error)
			completion?(result)
		}
		listingTask.resume()

		return listingTask
	}

	private static func handleFinishedListingTask(data: Data?, response: URLResponse?, error: Error?) -> APIResult<ThingList?> {

		let statusCode: Int
		if let httpResponse = response as? HTTPURLResponse {
			statusCode = httpResponse.statusCode
		} else {
			statusCode = 500
		}

		guard 200..<300 ~= statusCode else {
			DebugLogger.log("Request failed.")
			return APIResult(error: error ?? APIError.httpRequestFailed)
		}

		guard let data = data, data.count > 0 else {
			DebugLogger.log("There is no data in response.")
			return APIResult(error: error ?? APIError.emptyDataInResponse)
		}

		do {
			let list = try ThingList(from: data)
			return APIResult(value: list)
		} catch let error {
			DebugLogger.log("Failed to parse listing.")
			return APIResult(error: error)
		}

	}
}
