//
//  SongResultsTableViewCell.swift
//  AuxBox
//
//  Created by Ivan Teo on 29/4/21.
//

import UIKit

class SongResultsTableViewCell:UITableViewCell{
    
    let songImage = UIImageView()
//    let songTitle = UITextView()
//    let songArtist = UITextView()
    let songTitle = UILabel()
    let songArtist = UILabel()
    let queueButton = NextButton()
    let stackView = UIStackView()

    static let identifier = "SongResultsCell"

    var song : SongDetails? {
        didSet {
            
            if let imgURL = song?.image{
//                if let url = URL(string: imgURL){
//                    if let data = try? Data(contentsOf: url){
//                        songImage.image = UIImage(data:data)
//                    }
//                }
                SpotifyAuthManager.shared.downloadImage(from: imgURL) { (image) in
                    DispatchQueue.main.async {
                        self.songImage.image = image
                    }
                }
            }
            
            songTitle.text = song?.songName
            songArtist.text = song?.artist
//            songImage.image = song?.image
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: K.Colours.bgColour)
        queueButton.setupNextButton(title: "Queue", fontSize: 12, width: 60, height: 30)

        addSubview(queueButton)
        queueButton.translatesAutoresizingMaskIntoConstraints = false
        queueButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        queueButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        songImage.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        songImage.setupShadow()
        addSubview(songImage)
        songImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        songImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        songImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        songImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        songImage.image.
        
//        setupText(songTitle, fontSize: 12)
//        setupText(songArtist, fontSize: 8)
        songTitle.setupLabel(displayText: "", fontSize: 14)
        songArtist.setupLabel(displayText: "", fontSize: 12)
        songTitle.translatesAutoresizingMaskIntoConstraints = false
        songArtist.translatesAutoresizingMaskIntoConstraints = false
        songImage.translatesAutoresizingMaskIntoConstraints = false

        
       setupStackView(stackView, songTitle, songArtist)
        addSubview(stackView)
        setupStackViewConstraints(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    fileprivate func setupText(_ text: UITextView, fontSize: CGFloat) {
////        text.center = self.center
//        text.textColor = UIColor.white
//        text.font = UIFont(name: "Futura", size: fontSize)
//        text.isEditable = false
//        text.backgroundColor = .none
//        text.isScrollEnabled = false
//        text.textContainer.lineBreakMode = .byWordWrapping
//    }
    
    fileprivate func setupStackView(_ stackView: UIStackView, _ songTitle: UILabel, _ songArtist: UILabel) {
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalCentering
        stackView.alignment = UIStackView.Alignment.leading
//        stackView.spacing = -20
        stackView.addArrangedSubview(songTitle)
        stackView.addArrangedSubview(songArtist)
//        stackView.setCustomSpacing(-15, after: songTitle)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
        stackView.leadingAnchor.constraint(equalTo: self.songImage.trailingAnchor, constant:  20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.queueButton.leadingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        songTitle.bottomAnchor.constraint(equalTo: songArtist.topAnchor).isActive = true

    }
}

