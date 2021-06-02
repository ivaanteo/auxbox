//
//  ShadowImageView.swift
//  AuxBox
//
//  Created by Ivan Teo on 27/5/21.
//

import UIKit

extension UIImageView{
    
    func setupShadow(alphaInput: CGFloat = 0.5, heightInput: CGFloat = 4.0){
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: alphaInput).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: heightInput)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3
    }
    
    func addCircleGradiendBorder() {
        let gradientLayer = Colors().gl
//        gradientLayer?.frame =  CGRect(origin: CGPoint.zero, size: bounds.size)
            gradientLayer!.frame = bounds
            layer.cornerRadius = frame.size.width / 2
            clipsToBounds = true
            let shape = CAShapeLayer()
            let path = UIBezierPath(ovalIn: bounds)
            
            shape.lineWidth = 2
            shape.path = path.cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor // clear
            gradientLayer!.mask = shape
            layer.insertSublayer(gradientLayer!, at: 0)
        }
}

