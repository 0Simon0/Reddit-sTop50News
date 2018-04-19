//
//  ThingList+Parsing.swift
//  RedditClient
//
//  Created by Yana VV on 4/18/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

extension ThingList: JSONConstructable {

	convenience init(from json: JSONAny) throws {
		guard let json = json as? JSONDictionary else {
			throw JSONParsingError.invalidRootObject
		}
		guard let kind = json["kind"] as? String, kind == "Listing" else {
			throw JSONParsingError.missedRequiredField("kind")
		}
		guard let dataDictionary = json["data"] as? JSONDictionary else {
			throw JSONParsingError.missedRequiredField("data")
		}
//		guard let childrenCount = dataDictionary["dist"] as? Int, childrenCount > 0 else {
//			throw JSONParsingError.missedRequiredField("dist")
//		}
		guard let children = dataDictionary["children"] as? JSONArray else {
			throw JSONParsingError.missedRequiredField("children")
		}
		guard let after = dataDictionary["after"] as? String, let before = dataDictionary["before"] as? String else {
			throw JSONParsingError.missedRequiredField("after/before")
		}

		self.init()

		var list = [Thing]()
		children.forEach { (child) in
			do {
				let thing = try ThingParser.parse(from: child)
				list.append(thing)
			} catch ThingParserError.unknownThingKind {
				DebugLogger.log("Try to parse unknwon thing from listing json.")
			} catch {
				DebugLogger.log("Fail to parse thing from listing json.")
			}
		}

		self.list = list
		self.page = Page(after: after, before: before)
	}
}
