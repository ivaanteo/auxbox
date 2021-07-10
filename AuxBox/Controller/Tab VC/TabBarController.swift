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
//        let navController2 = SearchViewController()
        let navController2 = UINavigationController(rootViewController: SearchViewController())
        navController2.title = "Search"
        navController2.children[0].title = "Search"
        
        let navController3 = UINavigationController(rootViewController: ProfileViewController())
        self.setViewControllers([navController1, navController2, navController3], animated: false)
    }
}
