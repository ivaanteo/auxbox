//
//  StretchyTableHeader.swift
//  AuxBox
//
//  Created by Ivan Teo on 8/6/21.
//

import UIKit

class StretchyTableHeaderView: UIView {
    var imageViewHeight = NSLayoutConstraint()
    var imageViewBottom = NSLayoutConstraint()
    
    var playlistLabelBottom = NSLayoutConstraint()
    
    var containerView: UIView!
    var imageView: UIImageView!
    var playlistLabel: UILabel!
    
    var containerViewHeight = NSLayoutConstraint()
    
    var getMoreSongs: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        
        setViewConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        
    }
    
    func createViews() {
        // Container View
        containerView = UIView()
        containerView.backgroundColor = .clear
        let backgroundLayer = Colors().gl
        backgroundLayer?.frame = bounds
        containerView.layer.insertSublayer(backgroundLayer!, at: 0)
        self.addSubview(containerView)
        
        
        // ImageView for background
        imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .yellow
        imageView.contentMode = .scaleAspectFill
        
        // PlaylistLabel
        playlistLabel = UILabel()
        playlistLabel.setupLabel(displayText: "", fontSize: 24, overrideText: false)
        containerView.addSubview(playlistLabel)
        
        containerView.addSubview(imageView)
    }
    
    func setViewConstraints() {
        // UIView Constraints
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        // Container View Constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        
        // ImageView Constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageViewBottom = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        imageViewBottom = imageView.bottomAnchor.constraint(equalTo: playlistLabel.topAnchor, constant: -20)
        imageViewBottom.isActive = true
        imageViewHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        imageViewHeight.isActive = true
        playlistLabelBottom = playlistLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        playlistLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        playlistLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        // Label Constraints
        playlistLabel.translatesAutoresizingMaskIntoConstraints = false
        playlistLabelBottom.isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerViewHeight.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
//        let newY = -scrollView.contentOffset.y
        containerView.clipsToBounds = offsetY <= 0
//        imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2

        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top - 80, scrollView.contentInset.top - 80)
//        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
//        imageViewHeight.constant = 200
        
//        imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
//        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
        
    }
    
    
}
