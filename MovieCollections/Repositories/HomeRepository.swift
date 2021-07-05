//
//  HomeRepository.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import Combine

protocol HomeRepository {
    func getTrendingMovies() -> AnyPublisher<[Movie], Never>
    func getTopRatedMovies() -> AnyPublisher<[Movie], Never>
    func getUpcomingMovies() -> AnyPublisher<[Movie], Never>
    func getFavoriteCollections() -> AnyPublisher<[Movie], Never>
}

class HomeRepositoryImpl: HomeRepository {
    var apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func getTrendingMovies() -> AnyPublisher<[Movie], Never> {
        getMovies("movie/popular")
    }
    
    func getTopRatedMovies() -> AnyPublisher<[Movie], Never> {
        getMovies("movie/top_rated")
    }
    
    func getUpcomingMovies() -> AnyPublisher<[Movie], Never> {
        getMovies("movie/upcoming")
    }

    func getFavoriteCollections() -> AnyPublisher<[Movie], Never> {
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
        .map { Array($0.results[0].movies[0..<5]) }
        .catch { _ in Just([]) }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private func getMovies(_ path: String) -> AnyPublisher<[Movie], Never> {
        let response: AnyPublisher<MoviesResponse, Error> = apiService.get(url: path)
        
        return response.map { data -> [Movie] in
            return data.results
        }.catch { _ in
            Just([])
        }
        .receive(
            on: DispatchQueue.main
        ).eraseToAnyPublisher()
    }
}
