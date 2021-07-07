//
//  HomeViewModel.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import Combine

enum HomeSectionIndex: Int {
    case none
    case feature
    case collections
    case trending
    case topRated
    
    var header: String {
        switch self {
        case .trending: return "Top trending"
        case .topRated: return "Top Rated"
        case .collections: return "Favorite Collections"
        default: return ""
        }
    }
}

class HomeViewModel: Combinable {
    enum HomeVMSubscriptionKey: String {
        case upcoming
        case collections
        case topRated
        case trending
    }
    typealias SubscriptionKey = HomeVMSubscriptionKey
    
    var subscriptions: [SubscriptionKey : AnyCancellable] = [:]
    
    let repository: HomeRepository
    
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    @Published var sections: [HomeSection] = []
    
    func fetchData() {
        subscriptions[.trending] = repository.getTrendingMovies().sink { [weak self] movies in
            self?.parseMovie(movies: movies.map({ HomeMovie(data: $0, type: .horizontal) }), index: .trending)
        }
        
        subscriptions[.topRated] = repository.getTopRatedMovies().sink(receiveValue: { [weak self] movies in
            self?.parseMovie(movies: movies.map({ HomeMovie(data: $0, type: .horizontal) }), index: .topRated)
        })

        subscriptions[.upcoming] = repository.getUpcomingMovies().sink(receiveValue: { [weak self] movies in
            self?.parseMovie(movies: movies.map({ HomeMovie(data: $0, type: .feature) }), index: .feature)
        })

        subscriptions[.collections] = repository.getFavoriteCollections().sink(receiveValue: { [weak self] movies in
            self?.parseMovie(movies: movies.map({ HomeMovie(data: $0, type: .collection) }), index: .collections)
        })
    }
    
    func parseMovie(movies: [HomeMovie], index: HomeSectionIndex) {
        let section = HomeSection(movies: movies, title: index.header, index: index)
        sections = sections.safeAppend(section).sortByIndex()
    }
}

extension Array where Element == HomeSection {
    func safeAppend(_ element: HomeSection) -> Self {
        var result = self
        
        if let index = result.firstIndex(where: { $0.index == element.index }) {
            result[index] = element
        } else {
            result.append(element)
        }
        
        return result
    }
    
    func sortByIndex() -> Self {
        self.sorted { s1, s2 in
            return s1.index.rawValue < s2.index.rawValue
        }
    }
}
