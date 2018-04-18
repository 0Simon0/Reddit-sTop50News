//
//  RequestFactory.swift
//  RedditClient
//
//  Created by Yana VV on 4/18/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

class RequestFactory {

	static func requestForTopListing(count: Int = 0, limit: Int = 25, after: String? = nil, before: String? = nil) -> URLRequest {
		var params = [URLQueryItem]()
		params.append(URLQueryItem(name: "count", value: String(count)))
		params.append(URLQueryItem(name: "limit", value: String(limit)))
		if let after = after {
			params.append(URLQueryItem(name: "after", value: after))
		}
		if let before = before {
			params.append(URLQueryItem(name: "before", value: before))
		}

		let topListingURL = buildURL(base: baseAPIPath, path: "top", queryItems: params)
		var request = URLRequest(url: topListingURL)
		request.httpMethod = "GET"

		return request
	}

	static let baseAPIPath = "https://api.reddit.com"

	private static func buildURL(base: String, path: String, queryItems: [URLQueryItem]?) -> URL {
		let url = URL(string: base)!
		var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
		components.path = path
		components.queryItems = queryItems
		return components.url!
	}
}
