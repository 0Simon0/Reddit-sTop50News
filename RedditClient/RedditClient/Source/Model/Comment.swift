//
//  Comment.swift
//  RedditClient
//
//  Created by Yana VV on 4/18/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

struct Comment: Thing {

	let id: String
	let name: String
	static let kind = "t1"

	var author: String?
	var date: Date?
	var text: String?
}
