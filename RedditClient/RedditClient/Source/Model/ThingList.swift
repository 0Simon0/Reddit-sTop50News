//
//  ThingList.swift
//  RedditClient
//
//  Created by Yana VV on 4/18/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

final class ThingList: Codable {

	struct Page: Codable {
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

	enum CodingKeys: String, CodingKey {
		case things
		case page
	}

	enum ThingCodingKey: CodingKey {
		case thing
		case type
	}

	enum ThingType: String, Codable {
		case link = "link"
	}

	init(from decoder: Decoder) throws {
		var things = [Thing]()
		do {
			let values = try decoder.container(keyedBy: CodingKeys.self)
			let page = try values.decode(Page.self, forKey: .page)

			var thingsArray = try values.nestedUnkeyedContainer(forKey: CodingKeys.things)
			while(!thingsArray.isAtEnd) {
				let thing = try thingsArray.nestedContainer(keyedBy: ThingCodingKey.self)
				let type = try thing.decode(ThingType.self, forKey: ThingCodingKey.type)
				switch type {
				case .link:
					things.append(try thing.decode(Link.self, forKey: ThingCodingKey.thing))
				}
			}
			self.page = page
			self.things = things
		} catch {
			DebugLogger.log("While encoding ThingList: \(error)")
			self.page = nil
			self.things = things
		}
	}

	func encode(to encoder: Encoder) throws {
		do {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(page, forKey: CodingKeys.page)
		var thingsContainer = container.nestedUnkeyedContainer(forKey: CodingKeys.things)

		try self.things.forEach { (thing) in
			var thingContainer = thingsContainer.nestedContainer(keyedBy: ThingCodingKey.self)
			if let link = thing as? Link {
				try thingContainer.encode(ThingType.link, forKey: ThingCodingKey.type)
				try thingContainer.encode(link, forKey: ThingCodingKey.thing)
			}
		}
		} catch (let error) {
			DebugLogger.log("While encoding ThingList: \(error)")
		}
	}
}
