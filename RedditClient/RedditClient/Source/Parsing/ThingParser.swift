//
//  ThingParser.swift
//  RedditClient
//
//  Created by Yana VV on 4/19/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

enum ThingParserError: Error {
	case unknownThingKind
}

class ThingParser {

	enum KnownThingKind: String {
		case comment = "t1"
		case link = "t3"
	}

	static func parseThingKind(in json: JSONDictionary) throws -> KnownThingKind {
		guard let kindString = json["kind"] as? String else
		{
			throw JSONParsingError.missedRequiredField("kind")
		}
		guard let kind = KnownThingKind.init(rawValue: kindString) else {
			throw ThingParserError.unknownThingKind
		}
		return kind
	}

	static func parse(from json: JSONAny) throws -> Thing {
		guard let json = json as? JSONDictionary else {
			throw JSONParsingError.invalidRootObject
		}
		let kind = try parseThingKind(in: json)
		switch kind {
		case .link:
			return try Link(from: json)
		default:
			throw ThingParserError.unknownThingKind
		}
	}
}
