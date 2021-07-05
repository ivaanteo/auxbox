//
//  CustomLabel.swift
//  AuxBox
//
//  Created by Ivan Teo on 17/5/21.
//

import UIKit

extension UILabel{
    func setupLabel(displayText: String, fontSize: CGFloat, textColour : UIColor = UIColor.white, minScaleFactor: CGFloat = 0.75, minLines:Int = 2, overrideText: Bool = true, centerAlign: Bool = false){
        if overrideText{
            self.text = displayText
        }
        if centerAlign{
            self.textAlignment = .center
        }
        self.textColor = textColour
        self.font = UIFont(name: "Futura", size: fontSize)
        self.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = minScaleFactor
        self.numberOfLines = minLines
    }
}
