//
//  TabBarController.swift
//  AuxBox
//
//  Created by Ivan Teo on 9/7/21.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let navController1 = UINavigationController(rootViewController: HomeViewController())
        navController1.setupCustomNavBar()
        navController1.title = "Home"
        navController1.children[0].title = "Home"
        
        
        
        let navController2 = UINavigationController(rootViewController: SearchViewController())
        navController2.setupCustomNavBar()
        navController2.title = "Search"
        navController2.children[0].title = "Search"
        
        
        let navController3 = UINavigationController(rootViewController: ProfileViewController())
        navController3.setupCustomNavBar()
        navController3.title = "Profile"
        navController3.children[0].title = "Profile"
        
        self.setViewControllers([navController1, navController2, navController3], animated: false)
        self.view.tintColor = UIColor(named: K.Colours.orange)
        
        guard let items = self.tabBar.items else { return }
        
        let images = ["music.note.house", "magnifyingglass", "person"]
        
        for i in 0..<items.count{
            items[i].image = UIImage(systemName: images[i])
        }
        
    }
}
