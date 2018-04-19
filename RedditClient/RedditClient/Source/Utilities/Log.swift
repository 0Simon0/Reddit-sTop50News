//
//  Log.swift
//  RedditClient
//
//  Created by Yana VV on 4/19/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

class DebugLogger {
	static func log(_ message: String) {
		#if DEBUG
		print(message)
		#endif
	}
}
