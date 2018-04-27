//
//  Thing.swift
//  RedditClient
//
//  Created by Yana VV on 4/17/18.
//  Copyright © 2018 YV. All rights reserved.
//

import Foundation

protocol Thing : Codable {

	var id: String {get}
	var name: String {get}
}
