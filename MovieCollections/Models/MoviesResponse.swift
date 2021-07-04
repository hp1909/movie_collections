//
//  MoviesResponse.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation

struct MoviesResponse: Codable {
    var results: [Movie]
    var page: Int
}
