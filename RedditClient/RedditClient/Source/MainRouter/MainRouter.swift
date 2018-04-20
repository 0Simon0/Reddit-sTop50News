//
//  MainRouter.swift
//  RedditClient
//
//  Created by Yana VV on 4/20/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit

class MainRouter {

	static let shared = MainRouter()
	
	var window: UIWindow? = nil

	private(set) weak var rootNavigationController: UINavigationController?
	private(set) weak var newsScreen: NewsTableViewController?

	func showTop50NewsScreen() {
		let maxNewsCount = 85
		let configuration = TopNewsProvider<NewsInfoConvertable>.Configuration(maxNewsCount: maxNewsCount)
		let provider = TopNewsProvider<NewsInfoConvertable>(configuration: configuration)
		let newsScreen = NewsTableViewController.instantiate(newsProvider: provider)
		newsScreen.title = "Top \(maxNewsCount)"
		let rootNavigationController = UINavigationController(rootViewController: newsScreen)
		window?.rootViewController = rootNavigationController
		self.rootNavigationController = rootNavigationController
		self.newsScreen = newsScreen
	}
}
