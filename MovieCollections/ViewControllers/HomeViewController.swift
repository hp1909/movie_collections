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

typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSection>
typealias HomeDSSnapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSection>

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
        
        return collectionView
    }()

    private lazy var dataSource = self.createDataSource()
    
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
        subscriptions[.movies] = viewModel.$sections.sink(receiveValue: { [weak self] sections in
            var snapshot = HomeDSSnapshot()
            snapshot.appendSections(sections)
            sections.forEach { section in
                snapshot.appendItems([section], toSection: section)
            }
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        })
    }

    private func createDataSource() -> HomeDataSource {
        let dataSource = HomeDataSource(collectionView: collectionView) { collectionView, indexPath, movieSection in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeMoviesCollectionCell.reuseIndentifier,
                for: indexPath
            ) as? HomeMoviesCollectionCell
            cell?.data = movieSection

            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeSectionHeaderView.reuseIndentifier,
                for: indexPath
            ) as? HomeSectionHeaderView
            headerView?.titleLabel.text = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section].title

            return headerView
        }

        return dataSource
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 300
        if (dataSource.snapshot().sectionIdentifiers[indexPath.section].index == .feature) {
            height = 150
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch dataSource.snapshot().sectionIdentifiers[section].index {
        case .feature:
            return .zero
        default:
            return CGSize(width: collectionView.frame.width, height: 80)
        }
    }
}
