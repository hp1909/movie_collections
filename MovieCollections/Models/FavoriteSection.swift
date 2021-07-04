//
//  FavoriteSection.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/4/21.
//

import Foundation

struct FavoriteSection: Codable, Hashable {
    var genre: Genre
    var movies: [Movie]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(genre.id)
    }
    
    static func == (lhs: FavoriteSection, rhs: FavoriteSection) -> Bool {
        lhs.genre.id == rhs.genre.id
    }
}

struct FavoriteResponse: Codable {
    var results: [FavoriteSection]
}
