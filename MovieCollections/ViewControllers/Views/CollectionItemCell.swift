//
//  CollectionItemCell.swift
//  MovieCollections
//
//  Created by LW12860 on 05/07/2021.
//

import Foundation
import UIKit
import SnapKit

class CollectionItemCell: UICollectionViewCell, Reusable {
    static let reuseIndentifier: String = "CollectionItemCell"

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }

    private func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
