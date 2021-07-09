//
//  HomeSectionBackgroundView.swift
//  MovieCollections
//
//  Created by LW12860 on 08/07/2021.
//

import Foundation
import UIKit

class HomeSectionBackgroundView: UICollectionReusableView, Reusable {
    static var reuseIndentifier: String = "HomeSectionBackgroundView"
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 8
        backgroundColor = .yellow
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
