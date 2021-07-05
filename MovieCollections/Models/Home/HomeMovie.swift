//
//  HomeMovie.swift
//  MovieCollections
//
//  Created by LW12860 on 05/07/2021.
//

import Foundation

enum HomeType {
    case feature
    case collection
    case horizontal
}

struct HomeMovie: Hashable {
    var data: Movie
    var type: HomeType

    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
        hasher.combine(type)
    }

    static func ==(lhs: HomeMovie, rhs: HomeMovie) -> Bool {
        return lhs.data == rhs.data && lhs.type == rhs.type
    }
}
