//
//  NewsTableViewController.swift
//  RedditClient
//
//  Created by Yana VV on 4/17/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

	static func instantiate(newsProvider: TopNewsProvider<NewsInfoConvertable>) -> NewsTableViewController {
		let newsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsTableViewController") as! NewsTableViewController
		newsScreen.provider = newsProvider
		return newsScreen
	}

	var provider: TopNewsProvider<NewsInfoConvertable>? = nil {
		didSet {
			updateUI()
		}
	}

	private var news: [NewsInfoConvertable] {
		get {
			return provider?.news ?? []
		}
	}

	private var isLoadingMoreNews: Bool = false
	private var isEnableBottomRefresh: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.dataSource = self
		tableView.delegate = self

		tableView.estimatedRowHeight = 72
		tableView.rowHeight = UITableViewAutomaticDimension

		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(reloadNews), for: .valueChanged)
		reloadNews()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	private func updateUI() {
		updateStateOfBottomRefresh()
		tableView.reloadData()
	}

	@objc private func reloadNews() {
		refreshControl?.beginRefreshing()
		provider?.reloadNews {[weak self] in
			DispatchQueue.main.async {
				self?.refreshControl?.endRefreshing()
				self?.updateUI()
			}
		}
	}

	private func loadMoreNews() {
		isLoadingMoreNews = true
		provider?.loadMoreNews {[weak self] in
			DispatchQueue.main.async {
				self?.updateUI()
				self?.isLoadingMoreNews = false
			}
		}
	}

	private func updateStateOfBottomRefresh() {
		isEnableBottomRefresh = provider?.hasMoreToLoad ?? false
	}

	private func bottomPullToReload() {
		if !isLoadingMoreNews && isEnableBottomRefresh {
			loadMoreNews()
		}
	}

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offsetY = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height

		// fix
		if offsetY > contentHeight - scrollView.frame.height * 4 {
			bottomPullToReload()
		}
	}
}

extension NewsTableViewController {

	private func configureCell(_ cell: NewsTableViewCell, wiht newsInfo: NewsInfoConvertable) {
		cell.id = newsInfo.id
		cell.title = newsInfo.title
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return news.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
		configureCell(cell, wiht: news[indexPath.row])
		return cell
	}
}

extension NewsTableViewController {

	func showFullsizedPicture(_ pictureUrl: URL) {

	}
}

