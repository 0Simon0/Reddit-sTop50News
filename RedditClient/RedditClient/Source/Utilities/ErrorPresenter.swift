
//
//  ErrorPresenter.swift
//  RedditClient
//
//  Created by Yana VV on 4/25/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit

class ErrorPresenter {

	static func presentAlert(title: String, message: String, detailsMessage: String?, presenter: UIViewController) {

		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		if let detailsMessage = detailsMessage {
			alertController.addAction(UIAlertAction(title: "Details",
													style: .default,
													handler: { (action) in
														self.presentAlert(title: "Error details", message: detailsMessage, detailsMessage: nil, presenter: presenter)
			}))
		}

		alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

		presenter.present(alertController, animated: true, completion: nil)
	}
}

extension UIViewController {

	func presentAlert(title: String, message: String, detailsMessage: String?) {
		ErrorPresenter.presentAlert(title: title, message: message, detailsMessage: detailsMessage, presenter: self)
	}

}
