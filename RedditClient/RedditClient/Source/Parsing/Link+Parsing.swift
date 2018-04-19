//
//  Link+Parsing.swift
//  RedditClient
//
//  Created by Yana VV on 4/19/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

extension Link: JSONConstructable {
	init(from json: JSONAny) throws {
		guard let json = json as? JSONDictionary else {
			throw JSONParsingError.invalidRootObject
		}
		guard let kind = json["kind"] as? ThingParser.KnownThingKind, kind == .link else {
			throw JSONParsingError.missedRequiredField("kind")
		}
		guard let data = json["data"] as? JSONDictionary else {
			throw JSONParsingError.missedRequiredField("data")
		}
		guard let id = data["id"] as? String else {
			throw JSONParsingError.missedRequiredField("id")
		}
		let name = "\(kind)_\(id)"
		self.init(id: id, name: name)

		if let urlString = data["url"] as? String {
			url = URL(string: urlString)
		}
		title = data["title"] as? String
		author = data["author"] as? String

		if let created_utc = data["created_utc"] as? Int {
			date = Date(timeIntervalSince1970: Double(created_utc))
		}

		if let thumbnail_width = data["thumbnail_width"] as? Int, let thumbnail_height = data["thumbnail_height"] as? Int, let thumbnailURLString = data["thumbnail"] as? String, let thumbnailUrl = URL(string: thumbnailURLString) {
			thumbnailInfo = ThumbnailInfo(url: thumbnailUrl, width: thumbnail_width, height: thumbnail_height)
		}

		numberOfComments = data["num_comments"] as? Int
	}
}
