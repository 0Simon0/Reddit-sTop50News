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
	var thumbnailInfo: ThumbnailInfo? {
		willSet {
			if thumbnailInfo != newValue {
				thumbnailImage = nil
			}
		}
		didSet {
			if thumbnailInfo != oldValue {
				updateThumbnailUI()
				if let url = thumbnailInfo?.url, url.isImageURL {
					updateThubnailImage(from: url)
				}
			}
		}
	}

	var defaultThumbnailImage: UIImage? = UIImage(named: "DefaultThumbnail")
	var defaultPictureImage: UIImage? = UIImage(named: "DefaultPicture")
	var thumbnailImage: UIImage? {
		didSet {
			updateThumbnailUI()
		}
	}

	@IBOutlet private(set) var titleLabel: UILabel!
	@IBOutlet private(set) var descriptionLabel: UILabel!
	@IBOutlet private(set) var thumbnailImageView: UIImageView!

	override func prepareForReuse() {
		super.prepareForReuse()
		id = nil
		title = nil
		author = nil
		created = nil
		thumbnailInfo = nil
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

	private func setDefaultThumbnailImage() {
		guard let thumbnailInfo = thumbnailInfo, thumbnailInfo.url.isImageURL else {
			thumbnailImageView.image = defaultThumbnailImage
			return
		}
		thumbnailImageView.image = defaultPictureImage
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
		ImageLoader.shared.imageForUrl(url: url) { [weak self] (result) in
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
				DebugLogger.log("Can't load thumbnail. Error occurs: \(error)")
				break
			}
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		updateDescriptionUI()
		updateThumbnailUI()
	}
}
