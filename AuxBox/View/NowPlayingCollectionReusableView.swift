//
//  NowPlayingCollectionReusableView.swift
//  AuxBox
//
//  Created by Ivan Teo on 1/6/21.
//

import UIKit

class NowPlayingCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "nowPlayingCollectionReusableView"
    
    var song : SongDetails? {
        didSet {
            print("didSetSong")
            if let imgURL = song?.image{
                SpotifyAuthManager.shared.downloadImage(from: imgURL) { (image) in
                    DispatchQueue.main.async {
                        self.songImgView.image = image
                    }
                }
            }
            songName.text = song?.songName
            songArtist.text = song?.artist
        }
    }
    var songsInQueue:Int?{
        didSet{
            print("didSetSongsInQueue")
            if songsInQueue == 0{
                print("songsInQueue is 0")
                inQueueLabel.text = "No Songs in Queue"
            }else{
                inQueueLabel.text = (self.songsInQueue==1) ? "1 Song in Queue" : "\(self.songsInQueue!) Songs in Queue "
            }
        }
    }
    
    let songImgView = UIImageView()
    let songName = UILabel()
    let songArtist = UILabel()
    let stackView = UIStackView()
    let inQueueLabel = UILabel()
    
    let browseLabel = UILabel()
    let nowPlayingSubView = NowPlayingSubview()
    let combinedStackView = UIStackView()
    
    
    
    var newWidth: CGFloat{
        return frame.width-40
    }
    
    var newHeight: CGFloat{
        return frame.width*0.38
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
//        let gradientLayer = Colors().gl
//        // edit stuff to fit screen and appearance
////        gradientLayer!.frame = bounds
//        gradientLayer!.frame = CGRect(x: 0, y: 0, width: frame.width, height: newHeight)
////            .inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
//        gradientLayer!.cornerRadius = frame.height / 4
//        // insert sublayer
//        layer.insertSublayer(gradientLayer!, at: 0)
        setupViews()
    }
    
    func setupViews(){
//        songImgView.frame = CGRect(x: 0, y: 0, width: frame.height*0.9, height: frame.height*0.9)
        // YO THIS FOR THE SFSYMBOL LOL
        browseLabel.setupLabel(displayText: "Browse", fontSize: 24)
        songImgView.tintColor = .white
        songImgView.setupShadow()
        addSubview(songImgView)
        
        songName.setupLabel(displayText: song?.songName ?? "-", fontSize: 20)
        songArtist.setupLabel(displayText: song?.artist ?? "-", fontSize: 16)
        inQueueLabel.setupLabel(displayText: "-", fontSize: 16, textColour: UIColor(named: K.Colours.offWhite)!, overrideText: songsInQueue == nil)
        
        addSubview(inQueueLabel)
//        songName.widthAnchor.constraint(equalToConstant: self.frame.width*0.8).isActive=true
//        songArtist.widthAnchor.constraint(equalToConstant: self.frame.width*0.8).isActive=true
        
        setupStackView(stackView, songName, songArtist)
//        addSubview(stackView)
        setupStackView(combinedStackView, nowPlayingSubView, browseLabel)
        nowPlayingSubView.translatesAutoresizingMaskIntoConstraints = false
        nowPlayingSubView.widthAnchor.constraint(equalToConstant: self.frame.width).isActive=true
        nowPlayingSubView.heightAnchor.constraint(equalToConstant: newHeight).isActive=true
        addSubview(combinedStackView)
        combinedStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        combinedStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        combinedStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        combinedStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    
        songImgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.5*self.frame.height-(newWidth*0.1)).isActive = true
        songImgView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -12).isActive = true
        songImgView.translatesAutoresizingMaskIntoConstraints = false
        songImgView.widthAnchor.constraint(equalToConstant: newWidth*0.2).isActive = true
        songImgView.heightAnchor.constraint(equalToConstant: newWidth*0.2).isActive = true
//        setupStackViewConstraints(stackView)
        
        // Queue Label Constrains
        inQueueLabel.translatesAutoresizingMaskIntoConstraints=false
        inQueueLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.5*self.frame.height-(newWidth*0.1)).isActive = true
        inQueueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        inQueueLabel.topAnchor.constraint(equalTo: songImgView.bottomAnchor, constant: 8).isActive = true
//        inQueueLabel.widthAnchor.constraint(equalToConstant: self.frame.width*0.8).isActive=true
    }
    fileprivate func setupStackView(_ stackView: UIStackView, _ songTitle: UIView, _ songArtist: UILabel) {
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing = 0
        stackView.addArrangedSubview(songTitle)
        stackView.addArrangedSubview(songArtist)
//        stackView.setCustomSpacing(-15, after: songName)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
        stackView.leadingAnchor.constraint(equalTo: self.songImgView.trailingAnchor, constant:  20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -12).isActive = true
//        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        
    }
    
}
