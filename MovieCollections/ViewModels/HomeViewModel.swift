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
    case collections
    case feature
    case trending
    case topRated
    
    var header: String {
        switch self {
        case .feature: return "Featured"
        case .trending: return "Top trending"
        case .topRated: return "Top Rated"
        case .collections: return "Favorite Collections"
        default: return ""
        }
    }
}

class HomeViewModel {
    let repository: HomeRepository
    private var subscriptions = Set<AnyCancellable>()
    
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    @Published var sections: [HomeSection] = []
    
    func fetchData() {
        repository.getTrendingMovies().sink { [weak self] movies in
            self?.parseMovie(movies: movies, index: .trending)
        }.store(in: &subscriptions)
        
        repository.getTopRatedMovies().sink(receiveValue: { [weak self] movies in
            self?.parseMovie(movies: movies, index: .topRated)
        }).store(in: &subscriptions)

        repository.getUpcomingMovies().sink(receiveValue: { [weak self] movies in
            self?.parseMovie(movies: movies, index: .feature)
        }).store(in: &subscriptions)

        repository.getFavoriteCollections().sink(receiveValue: { [weak self] movies in
            self?.parseMovie(movies: movies, index: .collections)
        }).store(in: &subscriptions)
    }
    
    func parseMovie(movies: [Movie], index: HomeSectionIndex) {
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
