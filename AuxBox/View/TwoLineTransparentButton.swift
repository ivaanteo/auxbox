//
//  TwoLineTransparentButton.swift
//  AuxBox
//
//  Created by Ivan Teo on 6/7/21.
//

import UIKit

class TwoLineTransparentButton: UIButton {
    var btnTitleLabel = UILabel()
    var descLabel = UILabel()
    var creditsLabel = UILabel()
    var imgView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(width: CGFloat, height: CGFloat, bgAlpha: CGFloat, titleText: String, descText: String, includesImage: Bool = false ){
        super.init(frame: .zero)
        setupButton(width: width, height: height, bgAlpha: bgAlpha, titleText: titleText, descText: descText, includesImage: includesImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    override func layoutSubviews() {
//        <#code#>
//    }
    
    private func setupButton(width: CGFloat, height: CGFloat, bgAlpha: CGFloat, titleText: String, descText: String, includesImage: Bool){
        self.backgroundColor = UIColor.black.withAlphaComponent(bgAlpha)
        self.layer.cornerRadius = height/2
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        
        btnTitleLabel.setupLabel(displayText: titleText, fontSize: 16)
        descLabel.setupLabel(displayText: descText, fontSize: 12)
        
        addSubview(btnTitleLabel)
        addSubview(descLabel)
        
        btnTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        btnTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
        btnTitleLabel.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        btnTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        descLabel.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        descLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
        
        if includesImage{
            creditsLabel.setupLabel(displayText: "1", fontSize: 12)
            imgView.image = UIImage(systemName: "star.circle.fill")
            imgView.tintColor = UIColor(named: K.Colours.orange)
            
            imgView.translatesAutoresizingMaskIntoConstraints = false
            creditsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(imgView)
            addSubview(creditsLabel)
            
            imgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
            imgView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            creditsLabel.trailingAnchor.constraint(equalTo: imgView.leadingAnchor).isActive = true
            creditsLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
    }
    
}
