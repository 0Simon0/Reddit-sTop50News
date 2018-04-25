//
//  ActivityHUD.swift
//  RedditClient
//
//  Created by Yana VV on 4/25/18.
//  Copyright © 2018 YV. All rights reserved.
//

import UIKit

class ActivityHUD {

	var message: String? {
		didSet {
			messageLabel.text = message
		}
	}

	private let container: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.clear
		return view
	}()

	private let backgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		view.clipsToBounds = true
		view.layer.cornerRadius = 10
		return view
	}()

	private let activityIndicator: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
		return activityIndicator
	}()

	private let messageLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.white
		return label
	}()

	init() {
		construct()
	}

	func show(in view: UIView, animated: Bool) {

		activityIndicator.startAnimating()

		container.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(container)
		view.addConstraint(NSLayoutConstraint(item: container, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
		view.addConstraint(NSLayoutConstraint(item: container, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0))

		if (animated) {
			container.alpha = 0
			UIView.animate(withDuration: 0.3, animations: { [weak self] in
				self?.container.alpha = 1;
			}, completion:nil)
		}
	}

	func hide(afterDelay: Double = 0.0, animated: Bool) {
		let container = self.container
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + afterDelay) { [weak self] in
			if (animated) {
				container.alpha = 1
				UIView.animate(withDuration: 0.3, animations: {
					container.alpha = 0;
					}, completion: { [weak self] (finished) in
						container.removeFromSuperview()
						self?.activityIndicator.stopAnimating()
				})
			} else {
				container.removeFromSuperview()
				self?.activityIndicator.stopAnimating()
			}
		}
	}

	private func construct() {

		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(backgroundView)
		container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : backgroundView]))
		container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : backgroundView]))

		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 8.0
		stackView.distribution = .equalSpacing
		stackView.addArrangedSubview(activityIndicator)
		stackView.addArrangedSubview(messageLabel)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(stackView)
		container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[subview]-16-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : stackView]))
		container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[subview]-16-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview" : stackView]))
	}
}
