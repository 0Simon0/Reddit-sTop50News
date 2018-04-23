//
//  ImageLoader.swift
//  RedditClient
//
//  Created by Yana VV on 4/22/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit

enum ImageLoaderError : Error {
	case canNotCreateImageFromData
	case emptyDataFromServer
}

enum ImageLoaderResult {
	case success(UIImage)
	case failure(Error)

	init(image: UIImage) {
		self = .success(image)
	}

	init(error: Error?) {
		if let error = error {
			self = .failure(error)
		} else {
			self = .failure(APIError.unknown)
		}
	}
}

class ImageLoader {

	static let shared = ImageLoader()

	private var cache = NSCache<NSURL, UIImage>()
	private var session = URLSession(configuration: URLSessionConfiguration.default)

	func imageForUrl(url: URL, completionHandler:@escaping (_ result: ImageLoaderResult) -> ()) {
		guard let image = cachedImage(forKey: url) else {
			downloadImage(url: url, completionHandler: { (result) in
				completionHandler(result)
			})
			return
		}
		completionHandler(ImageLoaderResult(image: image))
	}

	private func downloadImage(url: URL, completionHandler:@escaping (_ result: ImageLoaderResult) -> ()) {
		let downloadTask = session.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
			if let error = error {
				completionHandler(ImageLoaderResult(error: error))
				return
			}

			guard let data = data else {
				completionHandler(ImageLoaderResult(error: ImageLoaderError.emptyDataFromServer))
				return
			}

			guard let image = UIImage(data: data) else {
				completionHandler(ImageLoaderResult(error: ImageLoaderError.canNotCreateImageFromData))
				return
			}

			self?.persist(image: image, forKey: url)
			completionHandler(ImageLoaderResult(image: image))
		})
		downloadTask.resume()
	}


	private func cachedImage(forKey url: URL) -> UIImage? {
		return cache.object(forKey: url as NSURL)
	}

	private func persist(image: UIImage, forKey url: URL) {
		cache.setObject(image, forKey: url as NSURL)
	}
}
