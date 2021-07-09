//
//  CreatedViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 7/5/21.
//

import UIKit
import CoreLocation

class CreatedViewController: UIViewController{
    var roomNameDesc:String?
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
    
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    var locationManager: CLLocationManager {
        get{
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)!.locationManager
        }
    }
    
    @objc func continueTapped(sender: UIButton!){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func endSessionTapped(sender: UIButton!){
        // pause music
        appRemote?.playerAPI?.pause()
        // delete room
        DatabaseManager.shared.deleteActiveRoom()
        // update user
        DatabaseManager.shared.deleteJoinedRoom()

        appRemote?.disconnect()
        
        locationManager.stopUpdatingLocation()
//        locationManager.stopMonitoringSignificantLocationChanges()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let backgroundLayer = Colors().gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
        
        roomNameLabel.setupLabel(displayText: "Room name", fontSize: 22)
        roomNameDescLabel.setupLabel(displayText: roomNameDesc!, fontSize: 28)
        auxCodeLabel.setupLabel(displayText: "Aux code", fontSize: 22)
        
        auxCodeDescLabel.setupLabel(displayText: DatabaseManager.shared.user?.auxCode ?? "nil", fontSize: 28)
        titleText.setupLabel(displayText: "Let's get this party going!", fontSize: 36)
        
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
//        titleText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.width * 0.1)).isActive = true
        titleText.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8).isActive = true
        
//        setupQueueButton(continueButton, btnTitle: "Continue", alpha: 0.8)
        continueButton.setupTransparentButton(btnTitle: "Continue", bgAlpha: 0.8, fontSize: 16, width: view.frame.width*0.8)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
//        setupQueueButton(endSessionButton, btnTitle: "End Session", alpha: 0.5)
        endSessionButton.setupTransparentButton(btnTitle: "End Session", bgAlpha: 0.5, fontSize: 16, width: view.frame.width*0.8)
        endSessionButton.addTarget(self, action: #selector(endSessionTapped), for: .touchUpInside)
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
//        text.numberOfLines = 2
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
//        stackView.setCustomSpacing(20, after: descLabel)
//        stackView.setCustomSpacing(-10, after: headerLabel)
//        stackView.setCustomSpacing(-10, after: headerLabel2)
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
}

