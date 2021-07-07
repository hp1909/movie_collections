//
//  MoviesCollectionCell.swift
//  MovieCollections
//
//  Created by LW12860 on 05/07/2021.
//

import Foundation
import UIKit

enum Design {
    static let itemSpacing: CGFloat = 4
    static let lineSpacing: CGFloat = 4
}

class MovieCollectionsCell: UICollectionViewCell, Reusable {
    static var reuseIndentifier: String = "MovieCollectionsCell"

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = Design.lineSpacing
        flowLayout.minimumInteritemSpacing = Design.itemSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemBackground

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(CollectionItemCell.self, forCellWithReuseIdentifier: CollectionItemCell.reuseIndentifier)

        return collectionView
    }()

    var data: HomeSection? = nil {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(collectionView)
    }

    private func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
}

extension MovieCollectionsCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.movies.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionItemCell.reuseIndentifier,
            for: indexPath
        ) as? CollectionItemCell else {
            return UICollectionViewCell()
        }
        cell.imageView.sd_setImage(data?.movies[indexPath.row].data.backdropFullPath)

        return cell
    }
}

extension MovieCollectionsCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 0, 1, 3, 4:
            return CGSize(
                width: (collectionView.frame.width - Design.itemSpacing * 2) / 3,
                height: (collectionView.frame.height - Design.lineSpacing) / 2
            )
        default:
            return CGSize(
                width: (collectionView.frame.width - Design.itemSpacing * 2) / 3,
                height: collectionView.frame.height
            )
        }
    }
}
