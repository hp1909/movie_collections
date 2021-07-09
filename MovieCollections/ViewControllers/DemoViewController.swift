//
//  DemoViewController.swift
//  MovieCollections
//
//  Created by LW12860 on 08/07/2021.
//

import Foundation
import UIKit
import SnapKit

typealias DemoDataSource = UICollectionViewDiffableDataSource<Section, Item>
typealias DemoSnapshot = NSDiffableDataSourceSnapshot<Section, Item>

class DemoViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let _collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
//        _collectionView.dataSource = self
        _collectionView.backgroundColor = .clear

        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")

        return _collectionView
    }()

    private lazy var dataSource = self.createDS()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        var snapshot = DemoSnapshot()
        let sections = [Section(id: 1), Section(id: 2)]
        let item1 = [Item(id: 1, selected: false), Item(id: 2, selected: true)]
        let item2 = [Item(id: 3, selected: true), Item(id: 4, selected: false)]
        snapshot.appendSections(sections)

        snapshot.appendItems(item1, toSection: sections[0])
        snapshot.appendItems(item2, toSection: sections[1])
        dataSource.apply(snapshot)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Random", style: .plain, target: self, action: #selector(tapRight))
    }

    @objc func tapRight() {
        var snapshot = DemoSnapshot()
        let sections = [Section(id: 1), Section(id: 2)]
        snapshot.appendSections(sections)
        let item1 = [Item(id: 1, selected: false), Item(id: 2, selected: true)]
        let item2 = [Item(id: 3, selected: false), Item(id: 4, selected: true)]
        snapshot.appendItems(item1, toSection: sections[0])
        snapshot.appendItems(item2, toSection: sections[1])

        dataSource.apply(snapshot, animatingDifferences: true)
    }



    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1/3)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }

    func createDS() -> DemoDataSource {
        let dataSource = DemoDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.contentView.backgroundColor = item.selected ? .blue : .green
            return cell
        }

        return dataSource
    }
}
//
//extension DemoViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        20
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
//        cell.contentView.backgroundColor = .lightGray
//
//        return cell
//    }
//}

struct Section: Hashable {
    var id: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Item: Hashable {
    var id: Int
    var selected: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id && lhs.selected == rhs.selected
    }
}
