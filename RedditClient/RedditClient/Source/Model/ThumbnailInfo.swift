//
//  ThumbnailInfo.swift
//  RedditClient
//
//  Created by Yana VV on 4/19/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

struct ThumbnailInfo: Equatable {
	let url: URL
	let width: Int
	let height: Int

	static func == (lhs: ThumbnailInfo, rhs: ThumbnailInfo) -> Bool {
		return lhs.url == rhs.url && lhs.width == rhs.width && lhs.height == rhs.height
	}
}
