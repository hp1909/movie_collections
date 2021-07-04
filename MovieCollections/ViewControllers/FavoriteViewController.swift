//
//  FavoriteViewController.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/4/21.
//

import Foundation
import UIKit
import SnapKit
import Combine

class FavoriteViewController: UIViewController, Combinable {
    enum Design {
        static let sideInsets: CGFloat = 16
        static let itemSpacing: CGFloat = 16
    }
    // MARK: Combine subscription keys
    enum FavoriteVCSubscriptionKey: String {
        case data
    }
    typealias SubscriptionKey = FavoriteVCSubscriptionKey
    var subscriptions: [SubscriptionKey : AnyCancellable] = [:]
    
    // MARK: Views declaration
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(MovieCompactCell.self, forCellWithReuseIdentifier: MovieCompactCell.reuseIndentifier)
        collectionView.register(
            HomeSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeaderView.reuseIndentifier
        )
        
        return collectionView
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Datas
    let viewModel = FavoriteViewModel(repository: FavoriteRepositoryImpl())
    var sections: [FavoriteSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        setupBinding()
        
        viewModel.loadInitialData()
    }
    
    func setupViews() {
        view.addSubview(collectionView)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search movies..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupBinding() {
        subscriptions[.data] = viewModel.$filteredSections.sink(receiveValue: { [weak self] sections in
            self?.sections = sections
            self?.collectionView.reloadData()
        })
    }
}

extension FavoriteViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].movies.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCompactCell.reuseIndentifier, for: indexPath) as? MovieCompactCell else {
            return UICollectionViewCell()
        }
        cell.movie = sections[indexPath.section].movies[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeSectionHeaderView.reuseIndentifier,
                for: indexPath
              ) as? HomeSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        headerView.titleLabel.text = sections[indexPath.section].genre.name
        return headerView
    }
}

extension FavoriteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(
            width: (collectionView.frame.width - 2 * Design.sideInsets - Design.itemSpacing) / 2,
            height: 250
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Design.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Design.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

extension FavoriteViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Handle search
        guard let searchKeyword = searchController.searchBar.text else { return }
        viewModel.filter(searchKeyword)
    }
}
