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

typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, HomeMovie>
typealias HomeDSSnapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeMovie>
typealias HomeCellRegistration<T: UICollectionViewCell> = UICollectionView.CellRegistration<T, HomeMovie>

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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createCompositionalLayout())
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()

    private lazy var dataSource = self.createDataSource()

    // MARK: Cell registration
    private let compactCellRegistration = HomeCellRegistration<MovieCompactCell> { cell, indexPath, movie in
        cell.movie = movie.data
    }

    private let expandCellRegistration = HomeCellRegistration<MovieExpandCell> { cell, indexPath, movie in
        cell.movie = movie.data
    }

    private let collectionCellRegistration = HomeCellRegistration<CollectionItemCell> { cell, indexPath, movie in
        cell.imageView.sd_setImage(movie.data.backdropFullPath)
    }

    private lazy var headerRegistration = UICollectionView.SupplementaryRegistration<HomeSectionHeaderView>(
        elementKind: UICollectionView.elementKindSectionHeader
    ) { [weak self] view, kind, IndexPath in
        view.titleLabel.text = self?.dataSource.snapshot().sectionIdentifiers[IndexPath.section].title
        view.onTap = { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
    }
    
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
                snapshot.appendItems(section.movies, toSection: section)
            }
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        })
    }

    private func createDataSource() -> HomeDataSource {
        let dataSource = HomeDataSource(collectionView: collectionView) { collectionView, indexPath, movie in
            var cell: UICollectionViewCell
            switch movie.type {
            case .feature:
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: self.expandCellRegistration,
                    for: indexPath,
                    item: movie
                )
            case .horizontal:
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: self.compactCellRegistration,
                    for: indexPath,
                    item: movie
                )
            case .collection:
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: self.collectionCellRegistration,
                    for: indexPath,
                    item: movie
                )
            }
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }
            let headerView = collectionView.dequeueConfiguredReusableSupplementary(
                using: self.headerRegistration,
                for: indexPath
            )

            return headerView
        }

        return dataSource
    }

    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self = self else { return nil }
            let sectionType = self.dataSource.snapshot().sectionIdentifiers[index].index
            switch sectionType {
            case .feature:
                return self.createFeatureLayoutSection(index)
            case .topRated, .trending:
                return self.createHorizontalLayoutSection(index)
            default:
                return self.createCollectionLayoutSection()
            }
        }

        return layout
    }

    func createFeatureLayoutSection(_ index: Int) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        itemLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(collectionView.frame.width - 32), heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: itemLayout, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return section
    }

    func createCollectionLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let smallItemsGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let smallItemGroup = NSCollectionLayoutGroup.vertical(layoutSize: smallItemsGroupSize, subitems: [layoutItem, layoutItem])

        let bigItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let bigLayoutItem = NSCollectionLayoutItem(layoutSize: bigItemSize)
        bigLayoutItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let mainGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(3/5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: mainGroupSize, subitems: [smallItemGroup, bigLayoutItem, smallItemGroup])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [createSupplementaryLayout()]

        return section
    }

    func createHorizontalLayoutSection(_ index: Int) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)
        itemLayout.contentInsets =  NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: itemLayout, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [createSupplementaryLayout()]

        return section
    }

    func createSupplementaryLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let supplementarySize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let supplementaryLayout = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: supplementarySize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        return supplementaryLayout
    }
}

//extension HomeViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var height: CGFloat = 250
//        switch dataSource.snapshot().sectionIdentifiers[indexPath.section].index {
//        case .feature:
//            height = 150
//        case .collections:
//            height = collectionView.frame.width * 3 / 5
//        default:
//            break
//        }
//        return CGSize(width: collectionView.frame.width, height: height)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return .zero
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        switch dataSource.snapshot().sectionIdentifiers[section].index {
//        case .feature:
//            return .zero
//        default:
//            return CGSize(width: collectionView.frame.width, height: 80)
//        }
//    }
//}
