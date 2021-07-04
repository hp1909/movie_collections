//
//  MainTabBarController.swift
//  MovieCollections
//
//  Created by Phuc Hoang on 7/3/21.
//

import Foundation
import UIKit

let tabbarDefaultIndexKey = "TAB_BAR_DEFAULT_INDEX"

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = .label
        setupVCs()
        let previousIndex = UserDefaults.standard.integer(forKey: tabbarDefaultIndexKey)
        self.selectedIndex = previousIndex
    }
    
    func setupVCs() {
        viewControllers = [
            createNavController(
                for: HomeViewController(),
                title: "Home",
                image: UIImage(systemName: "house"),
                selectedImage: UIImage(systemName: "house.fill")
            ),
            createNavController(
                for: FavoriteViewController(),
                title: "Favorite",
                image: UIImage(systemName: "heart"),
                selectedImage: UIImage(systemName: "heart.fill")
            ),
            createNavController(
                for: HomeViewController(),
                title: "Search",
                image: UIImage(systemName: "magnifyingglass.circle"),
                selectedImage: UIImage(systemName: "magnifyingglass.circle.fill")
            ),
            createNavController(
                for: HomeViewController(),
                title: "Settings",
                image: UIImage(systemName: "gearshape"),
                selectedImage: UIImage(systemName: "gearshape.fill")
            ),
        ]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        UserDefaults.standard.set(index, forKey: tabbarDefaultIndexKey)
    }
    
    private func createNavController(for viewController: UIViewController, title: String, image: UIImage?, selectedImage: UIImage?) -> UIViewController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.title = title
        
        return navController
    }
}
