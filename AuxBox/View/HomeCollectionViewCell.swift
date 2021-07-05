//
//  HomeCollectionViewCell.swift
//  AuxBox
//
//  Created by Ivan Teo on 1/6/21.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    static let identifier = "homeCollectionViewCell"
    
    var representedIdentifier: String = ""
    
    private let stackView = UIStackView()
    let playlistImageView = UIImageView()
    let playlistTitleLabel = UILabel()
    
//    @objc func playlistCellTouched(sender: UIView){
//        sender.alpha = 0.5
//    }
//    @objc func playlistCellTouchCancel(sender: UIView){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//          sender.alpha = 1.0
//      }
//    }
//    @objc func playlistCellTapped(sender: UIView){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//          sender.alpha = 1.0
//      }
//    }
    @objc func tapHandler(gesture: UITapGestureRecognizer) {

        // handle touch down and touch up events separately
        if gesture.state == .began {
            // do something...
            self.alpha = 0.5
        } else if gesture.state == .ended { // optional for touch up event catching
            // do something else...
            self.alpha = 1.0
        }
    }
    
//    var playlist:Playlist?{
//        didSet{
//            DispatchQueue.main.async {
//                self.playlistTitleLabel.text = self.playlist?.name
//            }
//            SpotifyAuthManager.shared.downloadImage(from: playlist!.imageURL) { (image) in
//                DispatchQueue.main.async {
//                    self.playlistImageView.image = image ?? UIImage(systemName: "music.note")
//                }
//            }
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // setups gradient layer here to prevent lag
        let gradientLayer = Colors().gl
        gradientLayer!.frame = bounds
        gradientLayer!.cornerRadius = frame.width * 0.1
        layer.insertSublayer(gradientLayer!, at: 0)
        
        
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistImageView.roundCorners(corners: [.topLeft, .topRight], radius: frame.width * 0.1)
//        playlistImageView.setupShadow()
//        playlistImageView.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
//        playlistImageView.heightAnchor.constraint(equalToConstant: frame.width).isActive = true
//        setupViews()
    }
    
    fileprivate func setupViews(){
//        playlistTitleLabel.setupLabel(displayText: "-", fontSize: 20, overrideText: false)
//        playlistTitleLabel.setupLabel(displayText: "-", fontSize: 18, centerAlign: true)
        
        playlistTitleLabel.setupLabel(displayText: "-", fontSize: 18)
        self.addSubview(playlistTitleLabel)
        self.addSubview(playlistImageView)
        
//        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
//        tap.minimumPressDuration = 0
//        tap.cancelsTouchesInView = false
//        contentView.addGestureRecognizer(tap)
        
        
        
        playlistImageView.translatesAutoresizingMaskIntoConstraints = false
        playlistTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        setupStackView(stackView)
//        self.addSubview(stackView)
//        playlistImageView.setupShadow()
//        playlistImageView.roundCorners(corners: [.topLeft, .topRight], radius: frame.height * 0.1)
//        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: frame.width*0.2).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -frame.width*0.15).isActive = true
        
//        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//                                          ,constant: -frame.width*0.08
        
//        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
//        playlistImageView.widthAnchor.constraint(equalToConstant: frame.width*0.6).isActive = true
//        playlistImageView.heightAnchor.constraint(equalToConstant: frame.width*0.6).isActive = true
//        playlistImageView.clipsToBounds = false
        
        playlistImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        playlistImageView.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        playlistImageView.heightAnchor.constraint(equalToConstant: frame.width).isActive = true
        
        playlistTitleLabel.topAnchor.constraint(equalTo: self.playlistImageView.bottomAnchor).isActive = true
        playlistTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        , constant: -frame.width*0.08
        playlistTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        playlistTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
    }
    
    fileprivate func setupStackView(_ stackView: UIStackView) {
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 0
        stackView.addArrangedSubview(playlistImageView)
        stackView.addArrangedSubview(playlistTitleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
