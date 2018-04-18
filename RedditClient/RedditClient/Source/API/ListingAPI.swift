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
	static func topList(_ session: URLSession?, page: ThingList.Page, limit: Int? = nil, completion: ((APIResult<ThingList?>) -> Void)?) -> URLSessionDataTask? {

		let session = session ?? URLSession.shared

		let request = RequestFactory.requestForTopListing()
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
			return APIResult(error: error ?? APIError.httpRequestFailed)
		}

		guard let data = data, data.count > 0 else {
			return APIResult(error: error ?? APIError.emptyDataInResponse)
		}

		guard let listingJson = try? JSONSerialization.jsonObject(with: data, options: []) else {
			return APIResult(error: APIError.parsingFailed)
		}

		guard let json = listingJson as? [String : Any] else {
			return APIResult(error: APIError.jsonObjectIsNotDictionary)
		}

		guard let list = ThingList(from: json) else {
			return APIResult(error: APIError.failedToParseFromJsonObject)
		}

		return APIResult(value: list)
	}
}
