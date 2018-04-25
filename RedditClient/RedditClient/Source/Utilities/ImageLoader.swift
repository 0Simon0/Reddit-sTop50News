//
//  ImageLoader.swift
//  RedditClient
//
//  Created by Yana VV on 4/22/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit

class ImageLoader {

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

	static let shared = ImageLoader()

	private let cache = NSCache<NSURL, UIImage>()
	private let session = URLSession(configuration: URLSessionConfiguration.default)

	deinit {
		session.invalidateAndCancel()
	}

	func imageForUrl(_ url: URL, completionHandler:@escaping (_ result: ImageLoaderResult) -> ()) {
		let completionInMainThread = { (_ result: ImageLoaderResult) in
			if Thread.isMainThread {
				completionHandler(result)
			} else {
				DispatchQueue.main.async {
					completionHandler(result)
				}
			}
		}
		guard let image = cachedImage(forKey: url) else {
			downloadImage(url: url, completionHandler: { (result) in
				completionInMainThread(result)
			})
			return
		}
		completionInMainThread(ImageLoaderResult(image: image))
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
