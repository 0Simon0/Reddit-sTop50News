//
//  URL+HttpsSchema.swift
//  RedditClient
//
//  Created by Yana VV on 4/23/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

extension URL {
	var httpsSchemaURL: URL {
		let correctedString = absoluteString.replacingOccurrences(of: "^http\\:\\/\\/", with: "https://", options: .regularExpression)
		guard let httpsUrl = URL(string: correctedString) else {
			return self
		}
		return httpsUrl
	}
}
