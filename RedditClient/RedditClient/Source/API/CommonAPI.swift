//
//  CommonAPI.swift
//  RedditClient
//
//  Created by Yana VV on 4/18/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

enum APIError : Error {
	case unknown 
	case httpRequestFailed
	case emptyDataInResponse
}

enum APIResult<T> {
	case success(T)
	case failure(Error)

	init(value: T) {
		self = .success(value)
	}

	init(error: Error?) {
		if let error = error {
			self = .failure(error)
		} else {
			self = .failure(APIError.unknown)
		}
	}
}
