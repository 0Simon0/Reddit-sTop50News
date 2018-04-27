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

	weak var rootNavigationController: UINavigationController?
	weak var newsScreen: NewsTableViewController?

	private func constructIfNeeded() {
		guard self.newsScreen == nil else {
			return
		}
		let newsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsTableViewController") as! NewsTableViewController
		newsScreen.restorationIdentifier = RestorationIdentifier.top50NewsRestorationIdentifier.rawValue
		self.newsScreen = newsScreen

		guard let rootNavigationController = rootNavigationController else {
			let rootNavigationController = UINavigationController(rootViewController: newsScreen)
			rootNavigationController.restorationIdentifier = RestorationIdentifier.rootNavigationRestorationIdentifier.rawValue
			self.rootNavigationController = rootNavigationController
			return
		}
		rootNavigationController.setViewControllers([newsScreen], animated: true)
	}

	func showTop50NewsScreen() {
		constructIfNeeded()
		guard let rootNavigationController = rootNavigationController else {
			assertionFailure("There is no any root navigation controller!")
			return
		}
		guard let newsScreen = newsScreen else {
			assertionFailure("There is no any News Screen to show!")
			return
		}
		if newsScreen.provider == nil {
			let maxNewsCount = 50
			let configuration = TopNewsProvider<NewsInfoConvertable>.Configuration(maxNewsCount: maxNewsCount)
			let provider = TopNewsProvider<NewsInfoConvertable>(configuration: configuration)
			newsScreen.provider = provider
		}
		window?.rootViewController = rootNavigationController
	}
}

extension MainRouter /* Restoration */ {

	fileprivate enum RestorationIdentifier: String {
		case top50NewsRestorationIdentifier = "top50NewsTableViewController"
		case rootNavigationRestorationIdentifier = "rootNavigationController"
	}
	
	func viewController(withRestorationIdentifierPath identifierComponents: [Any],
					 coder: NSCoder) -> UIViewController? {
		guard let restorationIdentifierString = identifierComponents.last as? String, let restorationIdentifier = RestorationIdentifier.init(rawValue: restorationIdentifierString) else {
			return nil
		}
		constructIfNeeded()
		switch restorationIdentifier {
		case .top50NewsRestorationIdentifier:
			return newsScreen
		case .rootNavigationRestorationIdentifier:
			return rootNavigationController
		}
	}
}
