//
//  JoinedRoomViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 16/5/21.
//

import UIKit

class JoinedRoomViewController:UIViewController{
    var roomNameDesc:String?
    var auxCodeDesc:String?

    let titleText = UILabel()

    let dismissViewButton = UIButton()

    let roomNameLabel = UILabel()
    let roomNameDescLabel = UILabel()
    let roomStackView = UIStackView()

    let auxCodeLabel = UILabel()
    var auxCodeDescLabel = UILabel()
    let auxStackView = UIStackView()

    let cardStackView = UIStackView()

    let continueButton = UIButton()
    let endSessionButton = UIButton()
    let buttonStackView = UIStackView()
    
    @objc func continueTapped(sender: UIButton!){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func leaveSessionTapped(sender: UIButton!){
        // delete room
//        DatabaseManager.shared.deleteActiveRoom()
        // update user
        guard let auxCode = DatabaseManager.user?.auxCode else {return}
        DatabaseManager.shared.updateRoomUsers(auxCode: auxCode, create: false)
        DatabaseManager.shared.deleteJoinedRoom()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .clear
        let backgroundLayer = Colors().gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)

//        setupText(roomNameLabel, displayText: "Room name", fontSize: 22)
//        setupText(roomNameDescLabel, displayText: roomNameDesc!, fontSize: 28)
//        setupText(auxCodeLabel, displayText: "Aux code", fontSize: 22)
//        setupText(auxCodeDescLabel, displayText: auxCodeDesc!, fontSize: 28)
//        setupText(titleText, displayText: "You're connected! Queue some BANGERS yo", fontSize: 36)
        
        guard let roomName = roomNameDesc else { return }
        guard let auxCode = auxCodeDesc else { return }
        roomNameLabel.setupLabel(displayText: "Room name", fontSize: 22)
        roomNameDescLabel.setupLabel(displayText: roomName, fontSize: 28)
        auxCodeLabel.setupLabel(displayText: "Aux code", fontSize: 22)
        auxCodeDescLabel.setupLabel(displayText: auxCode, fontSize: 28)
        titleText.setupLabel(displayText: "You're connected! Queue some BANGERS yo", fontSize: 36, minLines: 2)
        
        setupStackView(roomStackView, headerLabel: roomNameLabel, descLabel: roomNameDescLabel)
        setupStackView(auxStackView, headerLabel: auxCodeLabel, descLabel: auxCodeDescLabel)
        setupCardStackView(cardStackView,
                           stackView1: roomStackView,
                           stackView2: auxStackView)

        view.addSubview(cardStackView)
        setupStackViewConstraints(cardStackView)
        view.addSubview(titleText)
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.bottomAnchor.constraint(equalTo: cardStackView.topAnchor, constant: -30).isActive = true
        titleText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width * 0.1).isActive = true
        titleText.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8).isActive = true


//        setupQueueButton(continueButton, btnTitle: "Continue", alpha: 0.8)
        continueButton.setupTransparentButton(btnTitle: "Continue", bgAlpha: 0.8, fontSize: 16, width: view.frame.width*0.8)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
//        setupQueueButton(endSessionButton, btnTitle: "Leave Session", alpha: 0.5)
        endSessionButton.setupTransparentButton(btnTitle: "Leave Session", bgAlpha: 0.5, fontSize: 16, width: view.frame.width*0.8)
        endSessionButton.addTarget(self, action: #selector(leaveSessionTapped), for: .touchUpInside)
        setupStackView(buttonStackView, headerLabel: continueButton, descLabel: endSessionButton)
        view.addSubview(buttonStackView)
        buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

//    fileprivate func setupText(_ text: UILabel, displayText: String, fontSize: CGFloat) {
//        text.text = displayText
//        text.textColor = UIColor.white
//        text.font = UIFont(name: "Futura", size: fontSize)
//        text.backgroundColor = UIColor.white.withAlphaComponent(0)
//        text.adjustsFontSizeToFitWidth = true
//        text.lineBreakMode = .byWordWrapping
//        text.minimumScaleFactor = 0.75
//        text.numberOfLines = 3
//    }

    fileprivate func setupCardStackView(_ stackView: UIStackView, stackView1: UIStackView, stackView2: UIStackView) {
        stackView.axis  = .vertical
        stackView.distribution  = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 16
        
//        stackView.backgroundColor = .init(white: 0, alpha: 0.5)
        
        stackView.addBackground(color: .init(white: 0, alpha: 0.5))
        
        stackView.layer.cornerRadius = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(stackView1)
        stackView.addArrangedSubview(stackView2)
    }

    fileprivate func setupStackView(_ stackView: UIStackView, headerLabel: UIView, descLabel: UIView) {
        stackView.axis  = .vertical
        stackView.distribution  = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(descLabel)
    }

    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9).isActive = true
    }
//    fileprivate func setupQueueButton(_ btn: UIButton, btnTitle: String, alpha: Double) {
//        btn.setTitle(btnTitle, for: .normal)
//        btn.titleLabel?.font = UIFont(name: "Futura", size: 16)
//        btn.setTitleColor(.white, for: .normal)
//        btn.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(alpha))
//        btn.layer.cornerRadius = 20
//        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
//        btn.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
//        btn.layer.shadowOpacity = 1.0
//        btn.layer.shadowRadius = 3
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8).isActive = true
//        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
//    }
}
