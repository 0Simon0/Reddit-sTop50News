//
//  URL+PathExtension.swift
//  RedditClient
//
//  Created by Yana VV on 4/22/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

extension URL {
	var isImageURL: Bool {
		let pathExtension = self.pathExtension.lowercased()
		if pathExtension == "jpg" || pathExtension == "gif" || pathExtension == "png" {
			return true
		}
		return false
	}
}
