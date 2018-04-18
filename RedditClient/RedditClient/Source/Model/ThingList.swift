//
//  ThingList.swift
//  RedditClient
//
//  Created by Yana VV on 4/18/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

class ThingList {

	struct Page {
		let before: String
		let after: String

		var isEmpty: Bool {
			guard !after.isEmpty || !before.isEmpty else {
				return true
			}
			return false
		}
	}

	var list = [Thing]()
	var page: Page?
}
