//
//  LoginButton.swift
//  AuxBox
//
//  Created by Ivan Teo on 25/4/21.
//

import Foundation
import UIKit

class PaddedTextField: UITextField {
    var textPadding = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10
        )
    override init(frame:CGRect){
        super.init(frame:frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
extension PaddedTextField{
    func setupTextField(placeholderText: String, width: CGFloat){
        self.borderStyle = UITextField.BorderStyle.roundedRect
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
//        self.placeholder = placeholderText
        self.attributedPlaceholder = NSAttributedString.init(string: placeholderText, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize:12)])
        // Set UITextField background colour
        self.backgroundColor = UIColor.white
        // Set UITextField text color
        self.textColor = .black
    }
}
