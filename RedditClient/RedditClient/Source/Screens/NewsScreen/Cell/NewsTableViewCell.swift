//
//  NewsTableViewCell.swift
//  RedditClient
//
//  Created by Yana VV on 4/19/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

	var id: String?
	var title: String? {
		didSet {
			if title != oldValue {
				updateDescriptionUI()
			}
		}
	}
	var author: String?
	var created: Date?
	var thumbnailInfo: ThumbnailInfo?

	@IBOutlet var titleLabel: UILabel!

	override func prepareForReuse() {
		id = nil
		title = nil
		author = nil
		created = nil
		thumbnailInfo = nil
	}

	private func updateDescriptionUI() {
		titleLabel.text = title
	}
}
