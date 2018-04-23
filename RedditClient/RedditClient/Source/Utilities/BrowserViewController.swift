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
	private(set) var url: URL?
	private(set) var isLoading: Bool = false {
		didSet {
			navigationItem.rightBarButtonItem = isLoading ? loadingIndicator : nil
		}
	}

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

	private lazy var loadingIndicator: UIBarButtonItem = {
		let loadingIndicatorItem = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		loadingIndicatorItem.startAnimating()
		return UIBarButtonItem(customView: loadingIndicatorItem)
	}()

	func loadURL(_ url: URL) {
		let httpsSchemaUrl = url.httpsSchemaURL
		self.url = httpsSchemaUrl
		webView.load(URLRequest(url: httpsSchemaUrl))
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
		presentError(error)
	}

	func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		isLoading = false
		presentError(error)
	}

	private func presentError(_ error: Error) {
		let alertController = UIAlertController(title: "Error", message: "Can not open url \(url?.absoluteString ?? "")", preferredStyle: .alert)

		let detailAction = UIAlertAction(title: "Details", style: .default, handler: { [weak self] (action) in
			let errorDetailsAlertController = UIAlertController(title: "Error details", message: error.localizedDescription, preferredStyle: .alert)
			errorDetailsAlertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			self?.present(errorDetailsAlertController, animated: true, completion: nil)
			})
		alertController.addAction(detailAction)
		alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))

		present(alertController, animated: true, completion: nil)
	}
}

