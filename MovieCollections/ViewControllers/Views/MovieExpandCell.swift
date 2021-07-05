//
//  HomeMovieExpandCell.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import UIKit
import SDWebImage

class MovieExpandCell: UICollectionViewCell, Reusable {
    static let reuseIndentifier: String = "HomeMovieExpandCell"
    
    var movie: Movie? {
        didSet {
            self.imageView.sd_setImage(movie?.backdropFullPath)
            titleLabel.text = movie?.title
            ratingView.rating = CGFloat(movie?.voteAverage ?? 0)
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
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 1
        
        return label
    }()
    
    let ratingView = RatingView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubviews(imageView, titleLabel, ratingView)
        contentView.layer.cornerRadius = 24
        contentView.clipsToBounds = true
    }
    
    func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        ratingView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
}

class RatingView: UIView {
    var rating: CGFloat = 0 {
        didSet {
            ratingLabel.text = "\(rating)"
        }
    }
    let starIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .systemYellow
        
        return imageView
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .black
        label.font = .systemFont(ofSize: 12)
        label.text = "0"
        
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
        addSubviews(starIcon, ratingLabel)
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = .white
    }
    
    func setupLayout() {
        starIcon.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.leading.equalTo(starIcon.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }
    }
}
