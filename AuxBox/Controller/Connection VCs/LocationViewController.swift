//
//  LocationViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 27/4/21.
//

import UIKit
//import SwiftUI
//import SafariServices
import Firebase
import StoreKit
import SafariServices

class LocationViewController:UIViewController{
    
    let dismissViewButton = UIButton()
    
    let joinRoomLabel = UILabel()
    let joinRoomDescLabel = UILabel()
    let joinRoomTextField = PaddedTextField()
    let joinRoomButton = UIButton()
    let joinRoomStackView = UIStackView()
    
    let createRoomLabel = UILabel()
    let createRoomDescLabel = UILabel()
    let createRoomTextField = PaddedTextField()
    let createRoomButton = UIButton()
    let createRoomStackView = UIStackView()
    
    let combinedStackview = UIStackView()
    
    var accessToken = UserDefaults.standard.string(forKey: "access-token-key") {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: "access-token-key")
        }
    }
    
    func testFunc(){
        print("locationVC testFunc")
    }
    
    var didTapCreateRoom:Bool = false
    
    // MARK: - SPOTIFY VARIABLES
        var appRemote: SPTAppRemote {
            get {
                // points to app remote in scene delegate
                return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)!.appRemote
            }
        }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    //MARK: - Alerts
    private func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Button Actions
    @objc func dismissTapped(sender: UIButton!){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func joinButtonTapped(sender: UIButton!){
        // check if auxcode exists
        guard let enteredAuxCode = joinRoomTextField.text else {return}
        if enteredAuxCode != ""{
            DatabaseManager.shared.fetchData(collection: K.FStore.roomsCollection,
                                             document: enteredAuxCode,
                                             type: Room.self) { res in
                switch res{
                case .success(let room):
                    DatabaseManager.roomDetails = room
                    DatabaseManager.shared.updateUserRoom(auxCode: enteredAuxCode)
                    DatabaseManager.shared.updateRoomUsers(auxCode: enteredAuxCode, create: true)
                    // check that there are no errors
                    
                    let joinedRoomVC = JoinedRoomViewController()
                     joinedRoomVC.auxCodeDesc = enteredAuxCode
                    joinedRoomVC.roomNameDesc = room.roomName
                    DispatchQueue.main.async{
                        self.navigationController?.pushViewController(joinedRoomVC, animated: true)
                    }
                case .failure(let error):
                    self.presentAlert(title: "Oops, something went wrong!", message: error.rawValue)
                }
            }
            
//            DatabaseManager.shared.getRoomDetails(auxCode: enteredAuxCode){res in
//                switch res{
//                case .success(let room):
//                    DatabaseManager.shared.updateUserRoom(auxCode: enteredAuxCode)
//                    DatabaseManager.shared.updateRoomNewUser(auxCode: enteredAuxCode)
//                    // check that there are no errors
//
//                    let joinedRoomVC = JoinedRoomViewController()
//                     joinedRoomVC.auxCodeDesc = enteredAuxCode
//                    joinedRoomVC.roomNameDesc = room.roomName
//                    DispatchQueue.main.async{
//                        self.navigationController?.pushViewController(joinedRoomVC, animated: true)
//                    }
//                case .failure(let error):
//                    self.presentAlert(title: "Error", message: error.rawValue)
//                }
//            }
            
            
            // if so, add user uid to room
            // add auxcode to user
            // else, present alert to tell that room doesn't exist
        }
    }
    
    @objc func createButtonTapped(sender: UIButton!){
        // check if accesstoken exists
        // authenticate if does not...
        if createRoomTextField.text != ""{
            //            guard let currentUser = Auth.auth().currentUser else {return}
            
            if PersistenceManager.retrieveRefreshToken() == "" {
                // no refresh token, first time opening app
                // means you gotta get an ACCESS TOKEN, rather than a new refresh token
                guard let url = URL(string: "\(SpotifyAPI.accountURL)authorize?client_id=\(SpotifyAPI.clientID)&response_type=code&redirect_uri=\(SpotifyAPI.redirectURI)&scope=\(HeaderField.scope)") else {
                        print("error, failed to authorize spotify")
                    return}
                presentSafariVC(with: url)
            }
            
            self.didTapCreateRoom = true
            if appRemote.isConnected{
                // save room
                self.appRemote.playerAPI?.getPlayerState({ (res, err) in
                    guard err == nil else { return }
                    // get nowPlaying
                    let playerState = res as! SPTAppRemotePlayerState
                    // save room into firestore
                    self.saveRoom(playerState, roomName: self.createRoomTextField.text!)
                    self.transitionToCreatedVC()
            })
//                transitionToCreatedVC()
            }else{
                // begin auth and connection process
                if !appRemote.authorizeAndPlayURI(""){
                    // The Spotify app is not installed, present the user with an App Store page
                    showAppStoreInstall()
                }
            }
            
            
//            if appRemote.isConnected == false {
//                print("app not connected")
//                if appRemote.authorizeAndPlayURI("") == false {
//                    // The Spotify app is not installed, present the user with an App Store page
//                    showAppStoreInstall()
//                }
//            }else{
//                // this block should not be called since this screen should not be
//                // available if spotify is connected
//                print("app already connected, start playback")
//
//
//                appRemote.playerAPI?.getPlayerState({ (res, err) in
//                    print("error: \(err?.localizedDescription)")
//                   guard err == nil else { return }
//                   let playerState = res as! SPTAppRemotePlayerState
//                   if playerState.isPaused{
//                       self.startPlayback()
//                       // toggle a state change so that we know that room is being hosted
//                       // start background refresh
//                       // move to the next screen ONLY IF SUCCESS
//                   }
//                    DispatchQueue.main.async {
//                        let roomName = self.createRoomTextField.text!
//                        let auxCode = DatabaseManager.shared.retrieveAuxCode()
//                        self.saveRoom(playerState, roomName: roomName)
//                        DatabaseManager.shared.updateUserRoom(auxCode: auxCode)
//                       self.transitionToCreatedVC()
//                    }
//               })
//
//            }
        }
        
    }
    
    func transitionToCreatedVC() {
        DispatchQueue.main.async {
            let createdVC = CreatedViewController()
            createdVC.roomNameDesc = self.createRoomTextField.text
            self.navigationController?.pushViewController(createdVC, animated: true)
        }
    }
    
    fileprivate func saveRoom(_ playerState: SPTAppRemotePlayerState, roomName: String) {
        // saves room to Database and Global variable
        SpotifyAuthManager.shared.getSongDetails(trackURI: playerState.track.uri) { result in
                switch result{
                case .success(let currentTrack):
                    let room = Room(roomName: roomName,
                                    currentQueue: [],
                                    nowPlaying: currentTrack,
                                    users: [],
                                    toQueue: [])
                    DatabaseManager.shared.startActiveRoom(room: room)
                    if let auxCode = DatabaseManager.user?.auxCode{
                        DatabaseManager.shared.updateUserRoom(auxCode: auxCode)
                    }
                case .failure(let error):
                    self.presentAlert(title: "Error", message: error.rawValue)
                }
            }

    }
    
    //MARK: - Spotify Web API Auth
    func authorizeFirstTimeUser(with authCode: String){
        SpotifyAuthManager.shared.completeAuthorizeRequest(with: authCode) { results in
            guard let accessToken = results else {
                print("failed to authorize")
                return
            }
            DispatchQueue.main.async {
                //update ui
                print(accessToken, "got the first time user access token")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func presentSafariVC(with url: URL)
    {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor  = UIColor(named: K.Colours.orange)
        safariVC.preferredBarTintColor      = .white
        safariVC.delegate                   = self
        safariVC.modalPresentationStyle = .automatic
        present(safariVC, animated: true)
    }
    
    // MARK: - Spotify SDK
    
    private func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func willEnterForeground() {
        // check that button tapped
        if didTapCreateRoom && !appRemote.isConnected{
            appRemote.connect()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    fileprivate func setupCardStackView(_ stackView: UIStackView, headerLabel: UILabel, descLabel: UILabel, textField: PaddedTextField, btn: UIButton) {
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = 12.0
        //        stackView.backgroundColor = .init(white: 0, alpha: 0.5)
        stackView.addBackground(color: UIColor(white: 0, alpha: 0.5))
        //        stackView.layer.cornerRadius = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 30, left: 25, bottom: 30, right: 25)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(descLabel)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(btn)
    }
    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10).isActive = true
    }
    
    fileprivate func setupCombinedStackView() {
        combinedStackview.axis  = NSLayoutConstraint.Axis.vertical
        combinedStackview.distribution  = UIStackView.Distribution.equalSpacing
        combinedStackview.alignment = UIStackView.Alignment.center
        combinedStackview.spacing   = 20
        combinedStackview.translatesAutoresizingMaskIntoConstraints = false
        combinedStackview.addArrangedSubview(joinRoomStackView)
        combinedStackview.addArrangedSubview(createRoomStackView)
        combinedStackview.addArrangedSubview(dismissViewButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let backgroundLayer = Colors().gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
        
        // Text Field Delegates
        joinRoomTextField.delegate = self
        createRoomTextField.delegate = self
        
        // Spotify API
//        appRemote.delegate = self
        
//        appRemote.userAPI?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // first card
//        setupText(joinRoomLabel, displayText: "Join a room", fontSize: 24)
//        setupText(joinRoomDescLabel, displayText: "Enter the 6 digit aux code!", fontSize: 18)
//        setupQueueButton(joinRoomButton, btnTitle: "Join")
        joinRoomLabel.setupLabel(displayText: "Join a room", fontSize: 24)
        joinRoomDescLabel.setupLabel(displayText: "Enter the 6 digit aux code!", fontSize: 18)
        joinRoomTextField.setupTextField(placeholderText: "eg. A1B2C3", width: view.frame.width*0.8)
        joinRoomButton.setupTransparentButton(btnTitle: "Join", bgAlpha: 0.5, fontSize: 16, width: view.frame.width*0.8)
        joinRoomButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        setupCardStackView(joinRoomStackView,
                           headerLabel: joinRoomLabel,
                           descLabel: joinRoomDescLabel,
                           textField: joinRoomTextField,
                           btn: joinRoomButton)
        
        // second card
        createRoomLabel.setupLabel(displayText: "Create a room", fontSize: 24)
        createRoomDescLabel.setupLabel(displayText: "Pick a name for your room!", fontSize: 18)
        createRoomTextField.setupTextField(placeholderText: "eg. Toby's Uber", width: view.frame.width*0.8)
        createRoomButton.setupTransparentButton(btnTitle: "Create", bgAlpha: 0.5, fontSize: 16, width: view.frame.width*0.8)
        createRoomButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        setupCardStackView(createRoomStackView,
                           headerLabel: createRoomLabel,
                           descLabel: createRoomDescLabel,
                           textField: createRoomTextField,
                           btn: createRoomButton)
        dismissViewButton.setupTransparentButton(btnTitle: "Cancel", bgAlpha: 0.5, fontSize: 16, width: view.frame.width*0.8)
        setupCombinedStackView()
        dismissViewButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        view.addSubview(combinedStackview)
        setupStackViewConstraints(combinedStackview)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    } // end of view did load
}

extension LocationViewController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
//        if textField == joinRoomTextField{
//            UIView.animate(withDuration: 0.3) {
//                self.view.frame.origin.y = -(self.view.frame.height * 0.1)
//            }
//        }
        if textField == createRoomTextField{
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -(self.view.frame.height * 0.3)
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        UIView.animate(withDuration: 0.2) {
            self.view.frame.origin.y = 0
        }
    }
    
    func finishCreatingRoom(){
        // Check if Spotify Premium
        if didTapCreateRoom{// this prevents first load from calling this
            appRemote.userAPI?.fetchCapabilities(callback: { (res, err) in
                guard err == nil else {
                    self.presentAlert(title: "Error", message: err!.localizedDescription)
                    return }
                let capabilities = res as? SPTAppRemoteUserCapabilities
                if capabilities?.canPlayOnDemand == true{
                    self.appRemote.playerAPI?.getPlayerState({ (res, err) in
                        guard err == nil else { return }
                        // get nowPlaying
                        let playerState = res as! SPTAppRemotePlayerState
                        // save room into firestore
                        self.saveRoom(playerState, roomName: self.createRoomTextField.text!)
                        self.transitionToCreatedVC()
                })
                }
            })
        }
    }
    
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.layer.cornerRadius = 30
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
// MARK: - SPTAppRemoteUserAPIDelegate
//extension LocationViewController: SPTAppRemoteUserAPIDelegate {
//    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
//        print("delegate capabilities: ", capabilities.canPlayOnDemand)
//    }
//}

//extension LocationViewController: SPTAppRemoteDelegate{
//    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        self.didTapCreateRoom = false
//        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)!.appRemote = appRemote
//        // perform actions here ye
//        print("app remote did establish Connection")
//        appRemote.userAPI?.fetchCapabilities(callback: { (res, err) in
//            guard err == nil else {
//                print("fetch api error: ", err?.localizedDescription)
//                return }
//            let capabilities = res as? SPTAppRemoteUserCapabilities
//            if capabilities?.canPlayOnDemand == true{
//                self.appRemote.playerAPI?.getPlayerState({ (res, err) in
//                    guard err == nil else { return }
//                    let playerState = res as! SPTAppRemotePlayerState
//                    // save room into firestore
//                    self.saveRoom(playerState, roomName: self.createRoomTextField.text!)
//                    // update user in firestore so we know there's an active room
//                    // use result completion handler to check there's no errors
//                    // toggle a state change so that we know that room is being hosted
//                    // start background refresh
//                    // move to the next screen ONLY IF SUCCESS
//
//
////                    HomeViewController().appRemoteConnected()
//                    self.transitionToCreatedVC()
//            })
//            }
//        })
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//        print("didFailConnectionAttemptWithError")
//        //        rootViewController.appRemoteDisconnect()
//        presentAlert(title: "could not connect to spotify", message: "please try again")
//        self.didTapCreateRoom = false
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//        print("didDisconnectWithError")
////        rootViewController.appRemoteDisconnect()
//        self.didTapCreateRoom = false
//    }
//}

extension LocationViewController: SKStoreProductViewControllerDelegate {
    private func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            presentAlert(title: "Simulator In Use", message: "The App Store is not available in the iOS simulator, please test this feature on a physical device.")
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()], completionBlock: { (success, error) in
                loadingView.removeFromSuperview()
                if let error = error {
                    self.presentAlert(
                        title: "Error accessing App Store",
                        message: error.localizedDescription)
                } else {
                    self.present(storeProductViewController, animated: true, completion: nil)
                }
            })
        }
    }
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension LocationViewController:SFSafariViewControllerDelegate{
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        let currentURL = URL.absoluteString
        if currentURL.contains("\(SpotifyAPI.redirectURL)?code="){
            // check if theres a refresh token
            if PersistenceManager.retrieveRefreshToken() == "" {
                // no refresh token, first time opening app
                // means you gotta get an ACCESS TOKEN, rather than a new refresh token
                let endpoint = String(currentURL.split(separator: "=")[1])
                self.authorizeFirstTimeUser(with: endpoint)
            }
        }
    }
}
