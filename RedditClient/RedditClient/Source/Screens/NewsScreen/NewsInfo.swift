//
//  NewsInfo.swift
//  RedditClient
//
//  Created by Yana VV on 4/20/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

protocol NewsInfoConvertable {
	var id: String {get}
	var title: String? {get}
	var author: String? {get}
}
