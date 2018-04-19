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

	var author: String?
	var date: Date?
	var text: String?

	init(id: String, name: String) {
		self.id = id
		self.name = name
	}
}
