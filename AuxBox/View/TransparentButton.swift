//
//  TransparentButton.swift
//  AuxBox
//
//  Created by Ivan Teo on 17/5/21.
//

import UIKit

extension UIButton{
    func setupTransparentButton(btnTitle: String, bgAlpha: CGFloat, fontSize: CGFloat, width: CGFloat, height: CGFloat = 50){
        self.setTitle(btnTitle, for: .normal)
        self.titleLabel?.font = UIFont(name: "Futura", size: fontSize)
        self.setTitleColor(.white, for: .normal)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(bgAlpha)
        self.layer.cornerRadius = height/2
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
