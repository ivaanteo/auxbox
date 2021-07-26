//
//  PlaylistLoadingFooterView.swift
//  AuxBox
//
//  Created by Ivan Teo on 14/7/21.
//

import Foundation
class LoadingFooterView: UIView {
    static let footerId = "tableLoadingFooter"
    private let loadingSpinner = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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

