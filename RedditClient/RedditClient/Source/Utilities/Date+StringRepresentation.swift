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
		guard diff >= 60 * 60 else {
			let minutes = diff / 60
			return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
		}
		guard diff >= 60 * 60 else {
			let minutes = diff / 60
			return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
		}
		guard diff >= 60 * 60 * 24 else {
			let hours = diff / (60 * 60)
			return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
		}
		guard diff >= 60 * 60 * 24 * 7 else {
			let days = diff / (60 * 60 * 24)
			return "\(days) \(days == 1 ? "day" : "days") ago"
		}
		guard diff >= 60 * 60 * 24 * 31 else {
			let weeks = diff / (60 * 60 * 24 * 7)
			return "\(weeks) \(weeks == 1 ? "week" : "weeks") ago"
		}

		let dateComponents = Calendar.current.dateComponents([.year, .month], from: date, to: Date())
		let years = dateComponents.year!
		guard years > 0 else {
			let months = dateComponents.month!
			return "\(months) \(months == 1 ? "month" : "months") ago"
		}
		return "\(years) \(years == 1 ? "year" : "years") ago"
	}
}
