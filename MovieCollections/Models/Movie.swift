//
//  Movie.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation

struct Movie: Codable {
    var backdropPath: String?
    var posterPath: String?
    var id: Int
    var overview: String
    var title: String
    var voteAverage: Double
    var voteCount: Double
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case id
        case overview, title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backdropPath, forKey: .backdropPath)
        try container.encode(posterPath, forKey: .posterPath)
        try container.encode(id, forKey: .id)
        try container.encode(overview, forKey: .overview)
        try container.encode(title, forKey: .title)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encode(voteCount, forKey: .voteCount)
    }
    
    var backdropFullPath: String? {
        if backdropPath == nil && posterPath == nil {
            return nil
        }
        return "https://image.tmdb.org/t/p/w780/\(backdropPath ?? posterPath ?? "")"
    }
}

extension Movie: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
}
