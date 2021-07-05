//
//  HomeMovieCompactCell.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import UIKit

class MovieCompactCell: UICollectionViewCell, Reusable {
    static let reuseIndentifier: String = "HomeMovieCompactCell"
    
    var movie: Movie? {
        didSet {
            self.imageView.sd_setImage(movie?.backdropFullPath)
            self.titleLabel.text = movie?.title
            self.genresLabel.text = "Action, Sci-fic"
        }
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 1
        
        return label
    }()

    let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .systemGray
        label.numberOfLines = 1
        
        return label
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
        contentView.addSubviews(imageView, titleLabel, genresLabel)
        imageView.layer.cornerRadius = 36
        imageView.clipsToBounds = true
    }
    
    func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(16)
        }
        
        genresLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(16)
        }
    }
}
