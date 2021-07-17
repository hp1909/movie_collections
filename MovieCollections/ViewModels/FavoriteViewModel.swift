//
//  FavoriteViewModel.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/4/21.
//

import Foundation
import Combine

class FavoriteViewModel {
    let repository: FavoriteRepository
    
    var sections: [FavoriteSection] = [] {
        didSet {
            filteredSections = sections
        }
    }

    private var subscriptions = Set<AnyCancellable>()

    @Published var filteredSections: [FavoriteSection] = []
    
    init(repository: FavoriteRepository) {
        self.repository = repository
    }
    
    func loadInitialData() {
        repository.getFavoriteMovies().sink(receiveValue: { [weak self] sections in
            self?.sections = sections
        }).store(in: &subscriptions)
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
