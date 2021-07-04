//
//  FavoriteSection.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/4/21.
//

import Foundation

struct FavoriteSection: Codable {
    var genre: Genre
    var movies: [Movie]
}

struct FavoriteResponse: Codable {
    var results: [FavoriteSection]
}
