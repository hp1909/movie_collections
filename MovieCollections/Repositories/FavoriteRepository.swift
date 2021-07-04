//
//  FavoriteRepository.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/4/21.
//

import Foundation
import Combine

protocol FavoriteRepository {
    func getFavoriteMovies() -> AnyPublisher<[FavoriteSection], Never>
}

class FavoriteRepositoryImpl: FavoriteRepository {
    func getFavoriteMovies() -> AnyPublisher<[FavoriteSection], Never> {
        return Future<Data?, Never> { promise in
            DispatchQueue.global(qos: .userInteractive).async {
                if let path = Bundle.main.path(forResource: "favorite", ofType: "json") {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                        promise(.success(data))
                    } catch {
                        promise(.success(nil))
                    }
                } else {
                    promise(.success(nil))
                }
            }
        }.compactMap { $0 }
        .decode(type: FavoriteResponse.self, decoder: JSONDecoder())
        .map { $0.results }
        .catch { _ in Just([]) }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
