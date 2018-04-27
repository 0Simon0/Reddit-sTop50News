//
//  BrowserViewController.swift
//  RedditClient
//
//  Created by Yana VV on 4/23/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController {

	private(set) var webView: WKWebView!
	private(set) var url: URL? {
		didSet {
			canSaveToPhoto = url?.isImageURL ?? false
		}
	}
	private(set) var isLoading: Bool = false {
		didSet {
			updateRightBarButtonItem()
		}
	}
	private(set) var canSaveToPhoto: Bool = false {
		didSet {
			updateRightBarButtonItem()
		}
	}
	private lazy var imageLoader = ImageLoader()

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		createWebViewWithConfiguration(nil)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		createWebViewWithConfiguration(nil)
	}

	init(configuration: WKWebViewConfiguration) {
		super.init(nibName: nil, bundle: nil)
		createWebViewWithConfiguration(configuration)
	}

	private func createWebViewWithConfiguration(_ configuration: WKWebViewConfiguration?) {
		if let configuration = configuration {
			webView = WKWebView(frame: CGRect.zero, configuration: configuration)
		} else {
			webView = WKWebView()
		}
		webView.navigationDelegate = self

		webView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(webView)
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : webView]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : webView]))
	}

	private lazy var loadingIndicatorBarButtonItem: UIBarButtonItem = {
		let loadingIndicatorItem = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		loadingIndicatorItem.startAnimating()
		return UIBarButtonItem(customView: loadingIndicatorItem)
	}()
	private lazy var saveBarButtonItem: UIBarButtonItem = {
		return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveToPhotos))
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		restorationIdentifier = BrowserViewController.restorationIdentifierString
		restorationClass = BrowserViewController.self
		webView.restorationIdentifier = BrowserViewController.webViewRestorationIdentifierString
	}

	private func updateRightBarButtonItem() {
		guard !isLoading else {
			navigationItem.rightBarButtonItem = loadingIndicatorBarButtonItem
			return
		}
		navigationItem.rightBarButtonItem = canSaveToPhoto ? saveBarButtonItem : nil
	}

	func loadURL(_ url: URL) {
		let httpsSchemaUrl = url.httpsSchemaURL
		webView.load(URLRequest(url: httpsSchemaUrl))
		self.isLoading = webView.isLoading
		self.url = httpsSchemaUrl
	}

	@objc private func saveToPhotos(_ sender: UIBarButtonItem) {
		guard let url = url else {
			return
		}
		downloadImageAndSaveToPhotos(url)
	}
}

extension BrowserViewController : WKNavigationDelegate {

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		switch navigationAction.navigationType {
		case .linkActivated:
			decisionHandler(.cancel)
		default:
			decisionHandler(.allow)
		}
	}

	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		isLoading = true
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		isLoading = false

		if let title = webView.title , !title.isEmpty {
			self.title = title
		}
	}

	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		isLoading = false
		presentAlert(title: "Error", message: "Can not open url \(url?.absoluteString ?? "")", detailsMessage: error.localizedDescription)
	}

	func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		isLoading = false
		presentAlert(title: "Error", message: "Can not open url \(url?.absoluteString ?? "")", detailsMessage: error.localizedDescription)
	}
}

extension BrowserViewController {

	fileprivate func downloadImageAndSaveToPhotos(_ url: URL) {
		assert(url.isImageURL, "Url doesn't refer to image.")
		guard url.isImageURL else {
			return
		}
		if PhotoLibraryAssistant.isAuthorizedAccess() {
			let hud = ActivityHUD()
			hud.message = "Downloading..."
			hud.show(in: self.view, animated: true)
			imageLoader.imageForUrl(url) { (result) in
				switch result {
				case .success(let image):
					hud.message = "Saving..."
					PhotoLibraryAssistant.addImageToPhotos(image, completion: { (success, error) in
						if let error = error {
							DebugLogger.log("While saving to Photos error occurs. \(error.localizedDescription)")
						}
						hud.message = success ? "Success" : "Failed"
						hud.hide(afterDelay: 0.3, animated: true)
					})
					break

				case .failure(let error):
					DebugLogger.log("While saving to Photos error occurs. \(error.localizedDescription)")
					hud.message = "Failed"
					hud.hide(afterDelay: 0.3, animated: true)
					break
				}
			}
		} else {
			PhotoLibraryAssistant.showAuthorizationRequiredAlert(uiPresenter: self)
		}
	}
}

extension BrowserViewController: UIViewControllerRestoration {

	static let restorationIdentifierString = "BrowserViewController"
	static let webViewRestorationIdentifierString = "BrowserViewController.WebView"

	static func viewController(withRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
		guard let restorationIdentifier = identifierComponents.last as? String, BrowserViewController.restorationIdentifierString == restorationIdentifier else {
			return nil
		}
		return BrowserViewController()
	}
}

extension BrowserViewController {

	static let urlRestorableKey = "url"

	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		coder.encode(url, forKey:BrowserViewController.urlRestorableKey)
	}

	override func decodeRestorableState(with decoder: NSCoder) {
		super.decodeRestorableState(with: decoder)
		url = decoder.decodeObject(forKey: BrowserViewController.urlRestorableKey) as? URL
	}

	override func applicationFinishedRestoringState() {
		super.applicationFinishedRestoringState()
		if let url = url {
			loadURL(url)
		}
	}
}
