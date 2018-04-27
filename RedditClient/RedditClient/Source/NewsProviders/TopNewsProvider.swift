//
//  TopNewsProvider.swift
//  RedditClient
//
//  Created by Yana VV on 4/19/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

class TopNewsProvider<NewsItem>: Codable {

	struct Configuration: Codable {
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
	var news: [NewsItem] {
		let newsInfos =  list.things.compactMap({ (thing) -> NewsItem? in
			return thing as? NewsItem
		})

		guard let maxCount = configuration.maxNewsCount, maxCount < list.things.count else {
			return newsInfos
		}
		assert(false, "List can't be bigger then maxCount.")
		let news = Array(newsInfos[..<maxCount])
		return news
	}

	init(configuration: Configuration = Configuration.default) {
		self.configuration = configuration
	}

	private var newsLimitReached: Bool {
		guard let maxCount = configuration.maxNewsCount else {
			return false
		}
		return news.count >= maxCount
	}

	var hasMoreToLoad: Bool {
		guard !newsLimitReached else {
			return false
		}
		guard let page = list.page else {
			return false
		}
		return page.hasNext
	}

	var atLeastOnceLoaded: Bool {
		return list.page != nil
	}

	func reloadNews(completion: @escaping (() -> Void)) {
		let emptyPage = ThingList.Page()
		let limit = TopNewsProvider.prefferedLimit(with: configuration, forNewsCount: 0)
		ListingAPI.fetchTopList(session, fromPage: emptyPage, limit: limit) {[weak self] (result) in
			switch result {
			case .success(let newList):
				self?.list = newList
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
		let limit = TopNewsProvider.prefferedLimit(with: configuration, forNewsCount: news.count)
		weak var currentList = list
		ListingAPI.fetchTopList(session, fromPage: page, limit: limit) { (result) in
			switch result {
			case .success(let nextList):
				currentList?.appendTningList(nextList)
				break
			case .failure(let error):
				DebugLogger.log("Can't load next page. Error occur: \(error)")
				break
			}
			completion()
		}
	}

	private static func prefferedLimit(with configuration: Configuration, forNewsCount currentNewsCount: Int) -> Int {
		let prefferedPageSize = configuration.prefferedPageSize
		guard let maxCount = configuration.maxNewsCount else {
			return prefferedPageSize
		}
		let difference = maxCount - currentNewsCount
		assert(difference > 0, "Difference should be greater then 0.")
		guard difference > 0 else {
			return 0
		}
		return difference >= prefferedPageSize ? prefferedPageSize : difference
	}

	enum CodingKeys: String, CodingKey {
		case configuration
		case list
	}

	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		configuration = try values.decode(Configuration.self, forKey: .configuration)
		list = try values.decode(ThingList.self, forKey: .list)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(configuration, forKey: .configuration)
		try container.encode(list, forKey: .list)
	}
	
}
