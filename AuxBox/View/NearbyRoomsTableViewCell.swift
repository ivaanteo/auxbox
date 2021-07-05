//
//  NearbyRoomsTableViewCell.swift
//  AuxBox
//
//  Created by Ivan Teo on 2/7/21.
//

import UIKit

class NearbyRoomsTableViewCell: UITableViewCell{
    
    let roomNameLabel = UILabel()
    let distanceLabel = UILabel()
    static let cellIdentifier = "NearbyRoomsCell"
    
    let textStackView = UIStackView()
    
    let joinButton = UIButton()
    let numberOfUsersLabel = UILabel()
    let buttonStackView = UIStackView()
    
    var roomDetails : NearbyRoomsViewModel? {
        didSet {
            let usersText = roomDetails!.numberOfUsers == 1 ? "\(roomDetails!.numberOfUsers) user" : "\(roomDetails!.numberOfUsers) users"
            DispatchQueue.main.async {
                self.roomNameLabel.text = self.roomDetails?.name
                self.distanceLabel.text = "\(self.roomDetails!.distance)m away"
                self.numberOfUsersLabel.text = usersText
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        roomNameLabel.setupLabel(displayText: "", fontSize: 18, overrideText: false)
        // set gray colour
        distanceLabel.setupLabel(displayText: "", fontSize: 12, textColour: UIColor(named: K.Colours.offWhite)!, overrideText: false)
        
        roomNameLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfUsersLabel.translatesAutoresizingMaskIntoConstraints = false

        joinButton.setupTransparentButton(btnTitle: "Join", bgAlpha: 0.5, fontSize: 14, width: 60, height: 30)
//        numberOfUsersLabel.setupLabel(displayText: "", fontSize: 12, textColour: UIColor(named: K.Colours.offWhite)!, overrideText: false)
        numberOfUsersLabel.setupLabel(displayText: "", fontSize: 10, overrideText: false)
        
        setupStackView(textStackView, roomNameLabel, distanceLabel)
        addSubview(textStackView)
        addSubview(joinButton)
        addSubview(numberOfUsersLabel)
        
        joinButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        joinButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        numberOfUsersLabel.centerXAnchor.constraint(equalTo: self.joinButton.centerXAnchor).isActive = true
        numberOfUsersLabel.topAnchor.constraint(equalTo: self.joinButton.bottomAnchor, constant: 2).isActive = true
//        numberOfUsersLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 20).isActive = true
        
//        joinButton.leadingAnchor.constraint(equalTo: self.).isActive = true
        
//        setupStackView(buttonStackView, joinButton, numberOfUsersLabel)
//        addSubview(buttonStackView)
        setupStackViewConstraints(textStackView)
//        setupButtonStackViewConstraints(buttonStackView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupStackView(_ stackView: UIStackView, _ songTitle: UIView, _ songArtist: UIView) {
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalCentering
        stackView.alignment = UIStackView.Alignment.leading
//        stackView.spacing = 10
        stackView.addArrangedSubview(songTitle)
        stackView.addArrangedSubview(songArtist)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
//        stackView.trailingAnchor.constraint(equalTo: self.buttonStackView.trailingAnchor, constant: -20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.joinButton.leadingAnchor, constant: -20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 20).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    fileprivate func setupButtonStackViewConstraints(_ stackView: UIStackView){
        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
//        stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 20).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
