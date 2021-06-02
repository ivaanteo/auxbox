//
//  HomeCollectionViewCell.swift
//  AuxBox
//
//  Created by Ivan Teo on 1/6/21.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    static let identifier = "homeCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        let gradientLayer = Colors().gl
        // edit stuff to fit screen and appearance
        gradientLayer!.frame = bounds
//            .inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        gradientLayer!.cornerRadius = frame.height * 0.1
        // insert sublayer
        layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
