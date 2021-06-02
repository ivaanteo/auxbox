//
//  NextButton.swift
//  AuxBox
//
//  Created by Ivan Teo on 25/4/21.
//

import UIKit

class NextButton: UIButton{
    
    override init(frame:CGRect){
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // create an instance of the layer
        let gradientLayer = Colors().gl
        // edit stuff to fit screen and appearance
        gradientLayer!.frame = bounds
        gradientLayer!.cornerRadius = frame.height / 4
        // insert sublayer
        layer.insertSublayer(gradientLayer!, at: 0)
    }
}

extension NextButton {
    func setupNextButton(title: String, fontSize: CGFloat, width: CGFloat, height: CGFloat){
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont(name: "Futura", size: fontSize)
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
