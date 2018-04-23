//
//  NewsTableViewController.swift
//  RedditClient
//
//  Created by Yana VV on 4/17/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit

class NewsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet var tableView: UITableView!

	lazy var topRefreshControl: UIRefreshControl =  {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(reloadNews), for: .valueChanged)
		return refreshControl
	}()

	static func instantiate(newsProvider: TopNewsProvider<NewsInfoConvertable>) -> NewsTableViewController {
		let newsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsTableViewController") as! NewsTableViewController
		newsScreen.provider = newsProvider
		return newsScreen
	}

	var provider: TopNewsProvider<NewsInfoConvertable>? = nil {
		didSet {
			updateCachedNews()
		}
	}

	private var cachedNews: [NewsInfoConvertable] = [NewsInfoConvertable]() {
		didSet {
			if isViewLoaded {
				updateUI()
			}
		}
	}

	private var isLoadingMoreNews: Bool = false
	private var isEnableBottomRefresh: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self

		tableView.estimatedRowHeight = 100
		tableView.rowHeight = UITableViewAutomaticDimension

		tableView.refreshControl = topRefreshControl
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		manuallyReload()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc private func reloadNews() {
		provider?.reloadNews {[weak self] in
			DispatchQueue.main.async {
				self?.updateCachedNews()
				self?.tableView.refreshControl?.endRefreshing()
			}
		}
	}

	@objc private func loadMoreNews() {
		isLoadingMoreNews = true
		provider?.loadMoreNews {[weak self] in
			DispatchQueue.main.async {
				self?.updateCachedNews()
				self?.isLoadingMoreNews = false
			}
		}
	}

	private func updateCachedNews() {
		cachedNews = provider?.news ?? [NewsInfoConvertable]()
	}

	private func manuallyReload() {
		guard !topRefreshControl.isRefreshing else {
			return
		}
		let contentOffset = CGPoint(x: tableView.contentOffset.x, y: -topRefreshControl.bounds.size.height)

		topRefreshControl.beginRefreshing()
		tableView.setContentOffset(contentOffset, animated: true)

		reloadNews()
	}

	private func updateUI() {
		updateStateOfBottomRefresh()
		tableView.reloadData()
	}

	private func updateStateOfBottomRefresh() {
		isEnableBottomRefresh = provider?.hasMoreToLoad ?? false
	}

	private func bottomPullToReload() {
		if !isLoadingMoreNews && isEnableBottomRefresh {
			loadMoreNews()
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let preloadingCoefficient: CGFloat = 0.7
		let offsetY = scrollView.contentOffset.y
		let maxOffsetY = scrollView.contentSize.height - scrollView.frame.height
		if offsetY >= maxOffsetY * preloadingCoefficient {
			bottomPullToReload()
		}
	}
}

extension NewsTableViewController {

	private func configureCell(_ cell: NewsTableViewCell, wiht newsInfo: NewsInfoConvertable) {
		cell.id = newsInfo.id
		cell.title = newsInfo.title
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cachedNews.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
		configureCell(cell, wiht: cachedNews[indexPath.row])
		return cell
	}
}

extension NewsTableViewController {

	func showFullsizedPicture(_ pictureUrl: URL) {

	}
}

