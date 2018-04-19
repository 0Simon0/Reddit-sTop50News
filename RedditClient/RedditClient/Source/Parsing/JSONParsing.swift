//
//  JSONParsing.swift
//  RedditClient
//
//  Created by Yana VV on 4/19/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation


typealias JSONAny = Any
typealias JSONDictionary = Dictionary<String, AnyObject>
typealias JSONArray = Array<AnyObject>

enum JSONParsingError: Error {
	case invalidRootObject
	case missedRequiredField(String)
	case unknownValue(value: String, key: String)
}

protocol JSONConstructable {
	init(from json: JSONAny) throws
}

extension JSONConstructable {
	init(from data: Data) throws {
		let json = try JSONSerialization.jsonObject(with: data, options: [])
		try self.init(from: json)
	}
}
