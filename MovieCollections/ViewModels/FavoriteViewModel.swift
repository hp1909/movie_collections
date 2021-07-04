//
//  FavoriteViewModel.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/4/21.
//

import Foundation
import Combine

class FavoriteViewModel: Combinable {
    enum FavoriteVMSubscriptionKey: String {
        case initialData
    }
    typealias SubscriptionKey = FavoriteVMSubscriptionKey
    var subscriptions: [SubscriptionKey : AnyCancellable] = [:]
    
    let repository: FavoriteRepository
    
    var sections: [FavoriteSection] = [] {
        didSet {
            filteredSections = sections
        }
    }
    @Published var filteredSections: [FavoriteSection] = []
    
    init(repository: FavoriteRepository) {
        self.repository = repository
    }
    
    func loadInitialData() {
        subscriptions[.initialData] = repository.getFavoriteMovies().sink(receiveValue: { [weak self] sections in
            self?.sections = sections
        })
    }
    
    func filter(_ keyword: String) {
        guard !keyword.isEmpty else {
            filteredSections = sections
            return
        }
        
        filteredSections = sections.map({ section in
            let movies = section.movies.filter { $0.title.lowercased().contains(keyword.lowercased()) }
            return FavoriteSection(genre: section.genre, movies: movies)
        }).filter { !$0.movies.isEmpty }
    }
}
