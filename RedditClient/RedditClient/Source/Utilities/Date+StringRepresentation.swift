//
//  Date+StringRepresentation.swift
//  RedditClient
//
//  Created by Yana VV on 4/23/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

extension Date {

	static func stringRepresentationOfTime(sinceDate date: Date) -> String {
		let diff = Int(Date().timeIntervalSince1970 - date.timeIntervalSince1970)
		if diff < 3600 {
			let minutes = diff / 60
			return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
		}
		if diff < 3600 * 24 {
			let hours = diff / 3600
			return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
		}
		if diff < 3600 * 24 * 31 {
			let days = diff / 3600 / 24
			return "\(days) days ago"
		}
		if diff < 3600 * 24 * 31 * 365 {
			let months = diff / 3600 / 24 / 31
			return "\(months) \(months == 1 ? "month" : "months") ago"
		}
		let years = diff / 3600 / 365
		return "\(years) \(years == 1 ? "year" : "years") ago"
	}
}
