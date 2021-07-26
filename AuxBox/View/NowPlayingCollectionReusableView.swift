//
//  NowPlayingCollectionReusableView.swift
//  AuxBox
//
//  Created by Ivan Teo on 1/6/21.
//

import UIKit

class NowPlayingCollectionReusableView: UICollectionReusableView {
    
    static let cellId = "nowPlayingCollectionReusableView"
    
    let browseLabel = UILabel()
    let nowPlayingSubView = NowPlayingSubview()
    let combinedStackView = UIStackView()
    
    var newHeight: CGFloat{
        return frame.width*0.38
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        setupViews()
    }
    
    func setupViews(){
        browseLabel.setupLabel(displayText: "Browse", fontSize: 24)
        setupStackView(combinedStackView)
        setupNowPlayingConstraints()
        addSubview(combinedStackView)
        setupStackViewConstraints()
    }
    fileprivate func setupStackView(_ stackView: UIStackView) {
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing = 0
        stackView.addArrangedSubview(nowPlayingSubView)
        stackView.addArrangedSubview(browseLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func setupNowPlayingConstraints() {
        nowPlayingSubView.translatesAutoresizingMaskIntoConstraints = false
        nowPlayingSubView.widthAnchor.constraint(equalToConstant: self.frame.width).isActive=true
        nowPlayingSubView.heightAnchor.constraint(equalToConstant: newHeight).isActive=true
    }
    
    fileprivate func setupStackViewConstraints() {
        combinedStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        combinedStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        combinedStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        combinedStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    
}
