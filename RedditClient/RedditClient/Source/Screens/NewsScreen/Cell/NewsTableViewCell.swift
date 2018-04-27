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
	var author: String? {
		didSet {
			if author != oldValue {
				updateDescriptionUI()
			}
		}
	}
	var created: Date? {
		didSet {
			if created != oldValue {
				updateDescriptionUI()
			}
		}
	}
	var numberOfComments: Int? {
		didSet {
			if numberOfComments != oldValue {
				updateCommentsUI()
			}
		}
	}
	var thumbnailInfo: ThumbnailInfo? {
		willSet {
			if thumbnailInfo != newValue {
				thumbnailImage = nil
			}
		}
		didSet {
			if thumbnailInfo != oldValue {
				if let url = thumbnailInfo?.url {
					updateThubnailImage(from: url)
				}
				updateThumbnailUI()
			}
		}
	}
	var thumbnailTapHandler: (() -> Void)?

	@IBOutlet private(set) var titleLabel: UILabel!
	@IBOutlet private(set) var descriptionLabel: UILabel!
	@IBOutlet private(set) var commentsLabel: UILabel!
	@IBOutlet private(set) var thumbnailImageView: UIImageView!

	private let defaultThumbnailImage: UIImage? = UIImage(named: "DefaultThumbnail")
	private var thumbnailImage: UIImage? {
		didSet {
			updateThumbnailUI()
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		thumbnailImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbnailDidTap(_:))))
		thumbnailImageView.isUserInteractionEnabled = true

		updateDescriptionUI()
		updateThumbnailUI()
		updateCommentsUI()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		id = nil
		title = nil
		author = nil
		created = nil
		thumbnailInfo = nil
		thumbnailTapHandler = nil
	}

	private func updateDescriptionUI() {

		titleLabel.text = title

		var timeDescription = "some time ago"
		if let created = created {
			timeDescription = Date.stringRepresentationOfTime(sinceDate: created)
		}

		var authorDescription = "somebody"
		if let author = author {
			authorDescription = author
		}
		let description = "submitted \(timeDescription) by \(authorDescription)"
		descriptionLabel.text = description
	}

	private func updateCommentsUI() {
		guard let numberOfComments = numberOfComments, numberOfComments > 0 else {
			commentsLabel.text = "no comments yet"
			return
		}
		commentsLabel.text = "\(numberOfComments) \(numberOfComments == 1 ? "comment" : "comments")"
	}

	private func setDefaultThumbnailImage() {
		thumbnailImageView.image = defaultThumbnailImage
	}

	private func updateThumbnailUI() {
		guard let thumbnailImage = thumbnailImage else {
			setDefaultThumbnailImage()
			return
		}
		thumbnailImageView.image = thumbnailImage
	}

	private func updateThubnailImage(from url: URL) {
		let cellId = id
		ImageLoader.shared.imageForUrl(url) { [weak self] (result) in
			guard self?.id == cellId else {
				return
			}
			switch result {
			case .success(let image):
				DispatchQueue.main.async {
					self?.thumbnailImage = image
				}
				break
			case .failure(let error):
				DebugLogger.log("Can't load thumbnail by url: \(url). Error occurs: \(error)")
				break
			}
		}
	}

	@objc func thumbnailDidTap(_ sender: Any?) {
		thumbnailTapHandler?()
	}
}
