//
//  HomeMoviesCollectionCell.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import UIKit

enum MoviesCollectionType {
    case expand
    case compact
}

class MoviesHorizontalCell: UICollectionViewCell, Reusable {
    static let reuseIndentifier: String = "HomeMoviesCollectionCell"
    
    var data: HomeSection = HomeSection(movies: [], title: "", index: .none) {
        didSet {
            type = data.index == .feature ? .expand : .compact
            collectionView.reloadData()
        }
    }
    var type: MoviesCollectionType = .compact
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(MovieCompactCell.self, forCellWithReuseIdentifier: MovieCompactCell.reuseIndentifier)
        collectionView.register(MovieExpandCell.self, forCellWithReuseIdentifier: MovieExpandCell.reuseIndentifier)
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(collectionView)
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MoviesHorizontalCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.index != .none ? data.movies.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch data.index {
        case .feature:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieExpandCell.reuseIndentifier, for: indexPath) as! MovieExpandCell
            cell.movie = data.movies[indexPath.row].data
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCompactCell.reuseIndentifier, for: indexPath) as! MovieCompactCell
            cell.movie = data.movies[indexPath.row].data
            
            return cell
        }
    }
}

extension MoviesHorizontalCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 200
        if type == .expand {
            width = collectionView.frame.width - 32
        }
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
