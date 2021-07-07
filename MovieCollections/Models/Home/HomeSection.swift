//
//  HomeSection.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation

struct HomeSection: Hashable {
    var movies: [Movie]
    var title: String
    var index: HomeSectionIndex

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    static func ==(lhs: HomeSection, rhs: HomeSection) -> Bool {
        lhs.index == rhs.index
    }
}

typealias HomeItem = HomeSection
