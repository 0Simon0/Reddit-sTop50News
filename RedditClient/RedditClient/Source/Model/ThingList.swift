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
		private(set) var before: String?
		private(set) var after: String?
		private(set) var count: Int

		var hasNext: Bool {
			return (after != nil ? !after!.isEmpty : false)
		}

		var hasPrevious: Bool {
			return (before != nil ? !before!.isEmpty : false)
		}

		var isEmpty: Bool {
			return !hasNext && !hasPrevious
		}

		init(count: Int = 0, after: String? = nil, before: String? = nil) {
			assert(count >= 0, "Wrong value of count for page!")
			self.after = after
			self.before = before
			self.count = (count >= 0 ? count : 0)
		}

		func add(_ page: Page) -> Page {
			return Page(count: count + page.count, after: page.after, before: page.before)
		}
	}

	private(set) var things: [Thing]
	private(set) var page: Page?

	init() {
		self.things = [Thing]()
	}
	
	init(things: [Thing], page: Page) {
		self.things = things
		self.page = page
	}

	func appendTningList(_ list: ThingList) {
		guard let appendingPage = list.page else {
			return
		}
		self.things.append(contentsOf: list.things)
		guard let page = page else {
			self.page = appendingPage
			return
		}
		self.page = page.add(appendingPage)
	}
}
