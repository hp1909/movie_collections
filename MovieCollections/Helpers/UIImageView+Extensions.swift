//
//  UIImageView+Extensions.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/4/21.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func sd_setImage(_ url: String?) {
        guard let url = url, !url.isEmpty else { return }
        self.sd_setImage(with: URL(string: url)!, completed: nil)
    }
}
