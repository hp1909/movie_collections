//
//  HomeViewController.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import UIKit
import Combine
import SnapKit

class HomeViewController: UIViewController, Combinable {
    enum HomeSubscriptionKey: String {
        case movies
    }
    typealias SubscriptionKey = HomeSubscriptionKey
    var subscriptions: [SubscriptionKey: AnyCancellable] = [:]
    
    let viewModel = HomeViewModel(
        repository: HomeRepositoryImpl(
            apiService: APIService.shared
        )
    )
    
    // MARK: CollectionView declarations
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        
        collectionView.register(MovieExpandCell.self, forCellWithReuseIdentifier: MovieExpandCell.reuseIndentifier)
        collectionView.register(MovieCompactCell.self, forCellWithReuseIdentifier: MovieCompactCell.reuseIndentifier)
        collectionView.register(HomeMoviesCollectionCell.self, forCellWithReuseIdentifier: HomeMoviesCollectionCell.reuseIndentifier)
        collectionView.register(HomeSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeSectionHeaderView.reuseIndentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        setupBindings()
        
        viewModel.fetchData()
    }
    
    func setupViews() {
        view.addSubview(collectionView)
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupBindings() {
        subscriptions[.movies] = viewModel.$sections.sink(receiveValue: { [weak self] _ in
            self?.collectionView.reloadData()
        })
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeMoviesCollectionCell.reuseIndentifier, for: indexPath) as! HomeMoviesCollectionCell
        cell.data = viewModel.sections[indexPath.section]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeaderView.reuseIndentifier,
            for: indexPath
        ) as! HomeSectionHeaderView
        header.titleLabel.text = viewModel.sections[indexPath.section].title
        
        return header
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 300
        if (viewModel.sections[indexPath.section].index == .feature) {
            height = 150
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch viewModel.sections[section].index {
        case .feature:
            return .zero
        default:
            return CGSize(width: collectionView.frame.width, height: 80)
        }
    }
}
