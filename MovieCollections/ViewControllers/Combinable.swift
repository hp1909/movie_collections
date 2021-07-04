//
//  CombineViewController.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import UIKit
import Combine

protocol Combinable {
    associatedtype SubscriptionKey: Hashable
    var subscriptions: [SubscriptionKey: AnyCancellable] { get set }
}
