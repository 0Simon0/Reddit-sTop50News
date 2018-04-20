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
	static func fetchTopList(_ session: URLSession?, fromPage: ThingList.Page, limit: Int = 20, completion: ((APIResult<ThingList>) -> Void)?) -> URLSessionDataTask? {

		let session = session ?? URLSession.shared

		assert(limit > 0, "Shouldn't call fetch with limit less then 1.")
		guard limit > 0 else {
			completion?(APIResult(error: APIError.badRequest))
			return nil
		}

		let request = RequestFactory.requestForTopListing(count: fromPage.count, limit: limit, after: fromPage.after, before: nil)
		let listingTask = session.dataTask(with: request) { (data, response, error) in
			DebugLogger.log("Finished request with url: \((request.url?.debugDescription ?? "nil"))")
			let result = handleFinishedListingTask(data: data, response: response, error: error)
			completion?(result)
		}
		listingTask.resume()

		return listingTask
	}

	private static func handleFinishedListingTask(data: Data?, response: URLResponse?, error: Error?) -> APIResult<ThingList> {

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
