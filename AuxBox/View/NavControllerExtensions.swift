//
//  NavControllerExtensions.swift
//  AuxBox
//
//  Created by Ivan Teo on 16/7/21.
//

import UIKit

extension UINavigationController{
    func setupCustomNavBar(){
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Futura", size: 17)!, NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 1)]
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Futura", size: 26)!]
        self.navigationBar.barTintColor = UIColor(named: K.Colours.bgColour)
        self.navigationBar.tintColor = UIColor(named: K.Colours.orange)
    }
}
