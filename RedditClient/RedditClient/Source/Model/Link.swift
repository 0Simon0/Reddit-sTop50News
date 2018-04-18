//
//  Link.swift
//  RedditClient
//
//  Created by Yana VV on 4/17/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

struct Link: Thing {

	let id: String
	let name: String
	static let kind = "t3"

	var url: URL?
	var title: String?
	var author: String?
	var date: Date?
	var thumbnail: URL?
	var numberOfComments: Int?
}
