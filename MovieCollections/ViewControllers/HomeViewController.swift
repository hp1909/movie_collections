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

typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, Movie>
typealias HomeDSSnapshot = NSDiffableDataSourceSnapshot<HomeSection, Movie>

class HomeViewController: UIViewController {
    let viewModel = HomeViewModel(
        repository: HomeRepositoryImpl(
            apiService: APIService.shared
        )
    )
    
    // MARK: CollectionView declarations
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createCollectionViewLayout())
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()

    private lazy var dataSource = self.createDataSource()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        setupBindings()
        
        viewModel.fetchData()
    }

    // MARK: Setups
    func setupViews() {
        registerCells()
        view.addSubview(collectionView)
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupBindings() {
        viewModel.$sections.sink(receiveValue: { [weak self] sections in
            var snapshot = HomeDSSnapshot()
            snapshot.appendSections(sections)
            sections.forEach { section in
                snapshot.appendItems(section.movies, toSection: section)
            }
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }).store(in: &subscriptions)
    }

    // MARK: Cell registrations
    func registerCells() {
        collectionView.register(MovieBigCell.self, forCellWithReuseIdentifier: MovieBigCell.reuseIndentifier)
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIndentifier)
        collectionView.register(CollectionItemCell.self, forCellWithReuseIdentifier: CollectionItemCell.reuseIndentifier)

        collectionView.register(MoviesContainerCell.self, forCellWithReuseIdentifier: MoviesContainerCell.reuseIndentifier)
        collectionView.register(MovieCollectionsCell.self, forCellWithReuseIdentifier: MovieCollectionsCell.reuseIndentifier)

        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: SectionHeaderView.reuseIndentifier
        )
    }

    // MARK: Create datasource
    private func createDataSource() -> HomeDataSource {
        let dataSource = HomeDataSource(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, movie in
            guard let self = self else { return nil }
            return self.newCellConfigurations(collectionView, indexPath, movie)
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == "header" else { return nil }
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseIndentifier,
                for: indexPath
            ) as? SectionHeaderView
            headerView?.onTap = { [weak self] in
                self?.tabBarController?.selectedIndex = 1
            }
            headerView?.titleLabel.text = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section].title

            return headerView
        }

        return dataSource
    }

    // MARK: Old cell configurations
    func oldCellConfigurations(
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ item: HomeItem
    ) -> UICollectionViewCell? {
        let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        if section.index == .collections {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieCollectionsCell.reuseIndentifier,
                for: indexPath
            ) as? MovieCollectionsCell
            cell?.data = item

            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MoviesContainerCell.reuseIndentifier,
            for: indexPath
        ) as? MoviesContainerCell
        cell?.data = item

        return cell
    }

    // MARK: New Cell configurations
    func newCellConfigurations(
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ item: Movie
    ) -> UICollectionViewCell? {
        let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        switch section.index {
        case .feature:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieBigCell.reuseIndentifier, for: indexPath) as? MovieBigCell
            cell?.movie = item

            return cell
        case .collections:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionItemCell.reuseIndentifier, for: indexPath) as? CollectionItemCell
            cell?.imageView.sd_setImage(item.backdropFullPath)

            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIndentifier, for: indexPath) as? MovieCell
            cell?.movie = item

            return cell
        }
    }

    // MARK: CollectionView layout
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] index, _ in
            guard let self = self else { return nil }
            let section = self.dataSource.snapshot().sectionIdentifiers[index]

            switch section.index {
            case .collections:
                return self.createCollectionSection()
            case .feature:
                return self.createUpcomingSection()
            default:
                return self.createHorizontalSection()
            }
        }

        return layout
    }

    //   +----------------------------------+
    //   |                                  |
    //   |  +---------+--------+---------+  |
    //   |  |   1/2   |        |   1/2   |  |
    //   |  |         |        |         |  |
    //   |  |---------|        |---------|  |
    //   |  |   1/2   |        |   1/2   |  |
    //   |  |         |        |         |  |
    //   |  +---------+--------+---------+  |
    //   |                                  |
    //   |  |---------|--------|---------|  |
    //   |      1/3       1/3      1/3      |
    //   |                                  |<----- Screen
    //   |                                  |
    //   |                                  |
    //   +----------------------------------+

    func createCollectionSection() -> NSCollectionLayoutSection? {
        let smallItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        let smallItem = NSCollectionLayoutItem(layoutSize: smallItemSize)
        smallItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let smallGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let smallGroup = NSCollectionLayoutGroup.vertical(layoutSize: smallGroupSize, subitems: [smallItem])

        let bigItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let bigItem = NSCollectionLayoutItem(layoutSize: bigItemSize)
        bigItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let containerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(3/5))
        let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: containerGroupSize, subitems: [smallGroup, bigItem, smallGroup])

        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.boundarySupplementaryItems = [self.createSectionHeaderLayout()]

        return section
    }


    //   +----------------------------------+
    //   |                                  |
    //   |  +----------------------------+  |      +-----------------------------------------------------+
    //   |  |~~~~~~~~~~~~~~~~~~~~~~~~~~~~|  |      | Item sized:                                         |
    //   |  |~~~~~~~~~~~~~~~~~~~~~~~~~~~~|<-+------| *Width: FullWidth - 32, *Height: 150                |
    //   |  |~~~~~~~~~~~~~~~~~~~~~~~~~~~~|  |      |* spacing between items: 16                          |
    //   |  |~~~~~~~~~~~~~~~~~~~~~~~~~~~~|  |      +-----------------------------------------------------+
    //   |  +----------------------------+  |
    //   |                                  |
    //   |                                  |
    //   |                                  |
    //   |                                  |
    //   |                                  |<----- Screen
    //   |                                  |
    //   |                                  |
    //   +----------------------------------+

    func createUpcomingSection() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(collectionView.frame.width - 32), heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [self.createSectionHeaderLayout()]

        return section
    }

    //   +----------------------------------+
    //   |                                  |
    //   |  +------------+ +------------+   |      +-----------------------------------------------------+
    //   |  |~~~~~~~~~~~~| |~~~~~~~~~~~~|   |      | Item sized:                                         |
    //   |  |~~~~~~~~~~~~| |~~~~~~~~~~~~|<--+------| *Width: 200, *Height: 250                           |
    //   |  |~~~~~~~~~~~~| |~~~~~~~~~~~~|   |      |* spacing between items: 16                          |
    //   |  |~~~~~~~~~~~~| |~~~~~~~~~~~~|   |      +-----------------------------------------------------+
    //   |  +------------+ +------------+   |
    //   |  ==========     =========        |
    //   |  =====          =====            |
    //   |                                  |
    //   |                                  |
    //   |                                  |<----- Screen
    //   |                                  |
    //   |                                  |
    //   +----------------------------------+

    func createHorizontalSection() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.boundarySupplementaryItems = [self.createSectionHeaderLayout()]

        return section
    }


    // Size: (Width: Full width, Height: 60)
    func createSectionHeaderLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: "header", alignment: .top)

        return sectionHeader
    }
}
