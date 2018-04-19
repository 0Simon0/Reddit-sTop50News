//
//  TopNewsProvider.swift
//  RedditClient
//
//  Created by Yana VV on 4/19/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

class TopNewsProvider {

	struct Configuration {
		var maxNewsCount: Int? = nil
		var prefferedPageSize: Int = 20

		static var `default`: Configuration {
			return Configuration()
		}

		init(maxNewsCount: Int? = nil, prefferedPageSize: Int? = nil) {
			self.maxNewsCount = maxNewsCount
			if let prefferedPageSize = prefferedPageSize {
				self.prefferedPageSize = prefferedPageSize
			}
		}
	}

	private var list: ThingList = ThingList()
	private let session = URLSession.shared

	let configuration: Configuration
	var news: [Thing] {
		guard let maxCount = configuration.maxNewsCount, maxCount < list.things.count else {
			return list.things
		}
		assert(false, "List can't be bigger then maxCount.")
		let news = Array(list.things[..<maxCount])
		return news
	}

	init(configuration: Configuration = Configuration.default) {
		self.configuration = configuration
	}

	var newsLimitReached: Bool {
		guard let maxCount = configuration.maxNewsCount else {
			return false
		}
		return list.things.count >= maxCount
	}

	var hasMoreToLoad: Bool {
		guard !newsLimitReached else {
			return false
		}
		guard let page = list.page else {
			return true
		}
		return page.hasNext
	}

	func reloadNews(completion: @escaping (() -> Void)) {
		let emptyPage = ThingList.Page()
		let limit = TopNewsProvider.prefferedLimit(with: configuration, for: list)
		ListingAPI.fetchTopList(session, fromPage: emptyPage, limit: limit) { (result) in
			switch result {
			case .success(let newList):
				self.list = newList
				break
			case .failure(let error):
				DebugLogger.log("Can't reaload page. Error occur: \(error)")
				break
			}
			completion()
		}
	}

	func loadMoreNews(completion: @escaping (() -> Void)) {
		let page = list.page ?? ThingList.Page()
		let limit = TopNewsProvider.prefferedLimit(with: configuration, for: list)

		ListingAPI.fetchTopList(session, fromPage: page, limit: limit) { (result) in
			switch result {
			case .success(let nextList):
				self.list.appendTningList(nextList)
				break
			case .failure(let error):
				DebugLogger.log("Can't load next page. Error occur: \(error)")
				break
			}
			completion()
		}
	}

	private static func prefferedLimit(with configuration: Configuration, for list: ThingList) -> Int {
		let prefferedPageSize = configuration.prefferedPageSize
		guard let maxCount = configuration.maxNewsCount else {
			return prefferedPageSize
		}
		let difference = maxCount - list.things.count
		assert(difference > 0, "Difference should be greater then 0.")
		return difference >= prefferedPageSize ? prefferedPageSize : difference
	}
	
}
