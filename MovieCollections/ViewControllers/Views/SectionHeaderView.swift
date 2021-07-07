//
//  HomeSectionHeaderView.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import UIKit
import SnapKit

class SectionHeaderView: UICollectionReusableView, Reusable {
    static let reuseIndentifier: String = "HomeSectionHeaderView"
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        
        return label
    }()

    var onTap: (() -> Void)?
    
    private let trailingIcon: UIImageView = {
        let icon = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        
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
    
    func setupViews() {
        addSubviews(
            titleLabel,
            trailingIcon
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHeader(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc func tapHeader(_ sender: Any) {
        if titleLabel.text == "Favorite Collections" {
            onTap?()
        }
    }
    
    func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        trailingIcon.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(20)
        }
    }
}
