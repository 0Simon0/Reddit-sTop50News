//
//  ThingList.swift
//  RedditClient
//
//  Created by Yana VV on 4/18/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

final class ThingList {

	struct Page {
		let before: String?
		let after: String?

		var isEmpty: Bool {
			let isAfterEmpty = (after != nil ? after!.isEmpty : true)
			let isBeforeEmpty = (before != nil ? before!.isEmpty : true)
			return isAfterEmpty && isBeforeEmpty
		}

		init(after: String? = nil, before: String? = nil) {
			self.after = after
			self.before = before
		}
	}

	var list = [Thing]()
	var page = Page()
}
