//
//  PlaylistFooterView.swift
//  AuxBox
//
//  Created by Ivan Teo on 13/7/21.
//

import Foundation
class PlaylistFooterView: UICollectionReusableView {
    
    static let footerId = "playlistFooterView"
    private let loadingSpinner = UIActivityIndicatorView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        backgroundColor = .clear
        setupViews()
    }
    
    func setupViews(){
        loadingSpinner.style = .large
        loadingSpinner.color = .white
        loadingSpinner.center = self.center
        addSubview(loadingSpinner)
    }
    
    func startSpinning(){
        if !loadingSpinner.isAnimating{
            loadingSpinner.startAnimating()
        }
    }
    
    func stopSpinning(){
        if loadingSpinner.isAnimating{
            loadingSpinner.stopAnimating()
        }
    }
}
