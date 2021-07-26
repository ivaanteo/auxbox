//
//  PlaylistHeaderView.swift
//  AuxBox
//
//  Created by Ivan Teo on 13/7/21.
//

import Foundation
class PlaylistHeaderView: UICollectionReusableView {
    static let headerId = "playlistHeaderView"
    private let titleLabel = UILabel()
    let connectSpotifyButton = NextButton()
    let stackView = UIStackView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        setupViews()
    }
    
    func setupViews(){
        titleLabel.setupLabel(displayText: "Your Playlists", fontSize: 24)
        connectSpotifyButton.setupNextButton(title: "Sync playlists with Spotify", fontSize: 18, width: frame.width, height: 70)
        setupStackView()
    }
    
    func setupStackView(){
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing = 20
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(connectSpotifyButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
}
