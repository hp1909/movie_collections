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

typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>
typealias HomeDSSnapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>

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
        subscriptions[.movies] = viewModel.$sections.sink(receiveValue: { [weak self] sections in
            var snapshot = HomeDSSnapshot()
            snapshot.appendSections(sections)
            sections.forEach { section in
                snapshot.appendItems([section], toSection: section)
            }
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        })
    }

    // MARK: Cell registrations
    func registerCells() {
        collectionView.register(MovieBigCell.self, forCellWithReuseIdentifier: MovieBigCell.reuseIndentifier)
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIndentifier)
        collectionView.register(MoviesContainerCell.self, forCellWithReuseIdentifier: MoviesContainerCell.reuseIndentifier)
        collectionView.register(MovieCollectionsCell.self, forCellWithReuseIdentifier: MovieCollectionsCell.reuseIndentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIndentifier
        )
    }

    // MARK: Create datasource
    private func createDataSource() -> HomeDataSource {
        let dataSource = HomeDataSource(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, movieSection in
            guard let self = self else { return nil }
            return self.oldCellConfigurations(collectionView, indexPath, movieSection)
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
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
    func createCollectionViewLayout() -> UICollectionViewLayout? {
        nil
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
        nil
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
        nil
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
        nil
    }


    // Size: (Width: Full width, Height: 60)
    func createSectionHeaderLayout() -> NSCollectionLayoutBoundarySupplementaryItem? {
        nil
    }
}

// MARK: Flow layout delegate
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 250
        switch dataSource.snapshot().sectionIdentifiers[indexPath.section].index {
        case .feature:
            height = 150
        case .collections:
            height = collectionView.frame.width * 3 / 5
        default:
            break
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
