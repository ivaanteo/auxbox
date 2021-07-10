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
import CoreLocation
import GeoFire

class LocationViewController:UIViewController{
    
    lazy var backgroundView = UIView()
    
    lazy var dismissViewButton = UIButton()
    lazy var joinRoomLabel = UILabel()
    lazy var joinRoomDescLabel = UILabel()
    lazy var joinRoomTextField = PaddedTextField()
    lazy var joinRoomButton = UIButton()
    lazy var joinRoomStackView = UIStackView()
    
    lazy var createRoomLabel = UILabel()
    lazy var createRoomDescLabel = UILabel()
    lazy var createRoomTextField = PaddedTextField()
    lazy var createRoomButton = UIButton()
    lazy var createRoomStackView = UIStackView()
    lazy var combinedStackview = UIStackView()
    
    lazy var loadingSpinner = UIActivityIndicatorView()
    private var segmentedControl: UISegmentedControl!
    private let segmentedControlTabs = ["Join", "Create"]
    
    private lazy var nearbyRoomsLabel = UILabel()

    private var nearbyTableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    private lazy var combinedView = UIView()
    
    var didTapCreateRoom:Bool = false
    
    // Core Location Variables
    var nearbyRoomsViewModel = [NearbyRoomsViewModel]()
    
    var currentLocation: CLLocation?{
        didSet{
            print("current location: \(currentLocation!)")
        }
    }

    private var accessToken = UserDefaults.standard.string(forKey: "access-token-key") {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: "access-token-key")
        }
    }
    
    var locationManager: CLLocationManager {
        get{
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)!.locationManager
        }
    }
    
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
    
    
    // MARK: Segmented Control
    @objc func segmentChanged(sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 1{
            combinedView.isHidden = true
            createRoomStackView.isHidden = false
        }else{
            createRoomStackView.isHidden = true
            combinedView.isHidden = false
        }
    }
    
    
    //MARK: - Button Actions
    @objc func dismissTapped(sender: UIButton!){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func joinButtonTapped(sender: UIButton!){
        // check if auxcode exists
        
        guard let enteredAuxCode = joinRoomTextField.text else {return}
        if enteredAuxCode != ""{
            joinRoom(with: enteredAuxCode)
            // if so, add user uid to room
            // add auxcode to user
            // else, present alert to tell that room doesn't exist
        }else{
            presentAlert(title: "Oops!", message: "Seems like you forgot to enter an auxcode")
        }
    }
    
    @objc func createButtonTapped(sender: UIButton!){
        // check if accesstoken exists
        // authenticate if does not...
        if createRoomTextField.text != ""{
            showActivityIndicator(activityView: loadingSpinner)
            //            guard let currentUser = Auth.auth().currentUser else {return}
            
            if PersistenceManager.retrieveRefreshToken() == "" {
                // no refresh token, first time opening app
                // means you gotta get an ACCESS TOKEN, rather than a new refresh token
                guard let url = URL(string: "\(SpotifyAPI.accountURL)authorize?client_id=\(SpotifyAPI.clientID)&response_type=code&redirect_uri=\(SpotifyAPI.redirectURI)&scope=\(HeaderField.scope)") else {
                        hideActivityIndicator(activityView: loadingSpinner)
                        print("error, failed to authorize spotify")
                    return}
                hideActivityIndicator(activityView: loadingSpinner)
                presentSafariVC(with: url)
            }
            // allow for next step when safari vc presented
            self.didTapCreateRoom = true
            if appRemote.isConnected{
                // we gon play spotify for them
                appRemote.authorizeAndPlayURI("spotify:track:62vpWI1CHwFy7tMIcSStl8")
                finishCreatingRoom()
                
//                // save room
//                self.appRemote.playerAPI?.getPlayerState({ (res, err) in
//                    guard err == nil else { return }
//                    // get nowPlaying
//                    let playerState = res as! SPTAppRemotePlayerState
//                    // save room into firestore
//                    self.saveRoom(playerState, roomName: self.createRoomTextField.text!)
//                    self.transitionToCreatedVC()
//                })
                
//                transitionToCreatedVC()
            }else{
                // begin auth and connection process
                if !appRemote.authorizeAndPlayURI(""){
                    // The Spotify app is not installed, present the user with an App Store page
                    showAppStoreInstall()
                }
            }
        }else{
            showAlert(title: "Oops", message: "Please enter a valid title")
        }
    }
    
    @objc func cellJoinRoomTapped(_ sender: UIButton){
        joinRoom(with: nearbyRoomsViewModel[sender.tag].auxCode)
    }
    
    func transitionToCreatedVC() {
        DispatchQueue.main.async { [weak self] in
            let createdVC = CreatedViewController()
            createdVC.roomNameDesc = self?.createRoomTextField.text
            self?.navigationController?.pushViewController(createdVC, animated: true)
        }
    }
    
    fileprivate func saveRoom(_ playerState: SPTAppRemotePlayerState, roomName: String) {
        // saves room to Database and Global variable
        SpotifyAuthManager.shared.getSongDetails(trackURI: playerState.track.uri) { [weak self] result in
                switch result{
                case .success(let currentTrack):
                    var room: Room?
                    guard let uid = Auth.auth().currentUser?.uid else {print("error getting uid"); return }
                    
                    DispatchQueue.main.async {
                        // main thread for location manager
                        if let location = self?.locationManager.location{
                            let coordinates = location.coordinate
                            let hash = GFUtils.geoHash(forLocation: coordinates)
                            room = Room(roomName: roomName,
                                            currentQueue: [],
                                            nowPlaying: currentTrack,
                                            users: [uid],
                                            toQueue: [],
                                            normalQueue: [],
                                            geohash: hash,
                                            lat: coordinates.latitude,
                                            lng: coordinates.longitude
                                            )
                            DatabaseManager.shared.batchStartActiveRoom(room: room!)
                        }else{
                            room = Room(roomName: roomName,
                                            currentQueue: [],
                                            nowPlaying: currentTrack,
                                            users: [uid],
                                            toQueue: [],
                                            normalQueue: []
                                            )
                            DatabaseManager.shared.batchStartActiveRoom(room: room!)
                        }
                    }
                    
                    
                    
//                    DatabaseManager.shared.startActiveRoom(room: room!)
//                    if let auxCode = DatabaseManager.shared.user?.auxCode{
//                        DatabaseManager.shared.updateUserRoom(auxCode: auxCode)
//                    }
                    
                case .failure(let error):
                    self?.presentAlert(title: "Error", message: error.rawValue)
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
        refreshControl.beginRefreshing()
        getLocation()
        // set table is loading to true
    }
    
    fileprivate func setupCardStackView(_ stackView: UIStackView, headerLabel: UILabel, descLabel: UILabel, textField: PaddedTextField, btn: UIButton) {
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = 12.0
        //        stackView.backgroundColor = .init(white: 0, alpha: 0.5)
        
//        stackView.addBackground(color: UIColor(white: 0, alpha: 0.5))
        
        //        stackView.layer.cornerRadius = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.layoutMargins = UIEdgeInsets(top: 30, left: 25, bottom: 30, right: 25)
//        stackView.layoutMargins = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(descLabel)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(btn)
    }
    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.segmentedControl.bottomAnchor, constant: 20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10).isActive = true
    }
    
    fileprivate func setupCombinedStackView() {
        combinedStackview.axis  = NSLayoutConstraint.Axis.vertical
        combinedStackview.distribution  = UIStackView.Distribution.equalSpacing
        combinedStackview.alignment = UIStackView.Alignment.center
        combinedStackview.spacing   = 20
        combinedStackview.translatesAutoresizingMaskIntoConstraints = false
        combinedStackview.addArrangedSubview(joinRoomStackView)
        combinedStackview.addArrangedSubview(createRoomStackView)
        combinedStackview.addArrangedSubview(nearbyTableView)
        combinedStackview.addBackground(color: .init(white: 0, alpha: 0.5))

//        combinedStackview.addArrangedSubview(dismissViewButton)
    }
    
    deinit {
        print("location vc did deinit")
    }
    
    // MARK: Join Room
    func joinRoom(with auxCode: String){
        showActivityIndicator(activityView: loadingSpinner)
        DatabaseManager.shared.fetchData(collection: K.FStore.roomsCollection,
                                         document: auxCode,
                                         type: Room.self) { res in
            switch res{
            case .success(let room):
                DatabaseManager.shared.batchJoinRoom(auxCode: auxCode, room: room, exitRoom: false) { err in
                    // present alert if cannot batch join
                    guard err == nil else {
                        DispatchQueue.main.async {
                            self.hideActivityIndicator(activityView: self.loadingSpinner)
                            self.presentAlert(title: "Oops!", message: "Error joining room: \(err!.localizedDescription)")
                        }
                        return }
                    
                    let joinedRoomVC = JoinedRoomViewController()
                     joinedRoomVC.auxCodeDesc = auxCode
                    joinedRoomVC.roomNameDesc = room.roomName
                    DispatchQueue.main.async{
                        self.hideActivityIndicator(activityView: self.loadingSpinner)
                        self.navigationController?.pushViewController(joinedRoomVC, animated: true)
                    }
                }
            case .failure(_):
                self.hideActivityIndicator(activityView: self.loadingSpinner)
                self.presentAlert(title: "Oops!", message: "We couldn't find a room with that auxcode")
            }
        }
    }
    
    // MARK: Location Methods
    func retrievedLocation(location: CLLocation){
        print("location retrieved: \(location.coordinate)")
        let hash = GFUtils.geoHash(forLocation: location.coordinate)
        print("hash \(hash)")
        // here, run the function call to get nearest locations
        // function can call multiple times in a row. make sure it cancels api request
        DatabaseManager.shared.fetchNearestLocations(location: location){ (res) in
            switch res{
            case.success(let nearbyRooms):
                self.nearbyRoomsViewModel = nearbyRooms
                // reload tableview
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.nearbyTableView.reloadData()
                }
                // set table is loading to false
            case .failure(let err):
                print("Error fetching nearest locations \(err.localizedDescription)")
                // set table is loading to false
            }
        }
        
        // update table
    }
    
    @objc func getLocation(){
//        locationManager.requestWhenInUseAuthorization()
//        if #available(iOS 14.0, *) {
//            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "browseNearby")
//        } else {
//            // Fallback on earlier versions
//            locationManager.requestWhenInUseAuthorization()
//        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
//        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func finishCreatingRoom(){
        // Check if Spotify Premium
        if didTapCreateRoom{// this prevents first load from calling this
            showActivityIndicator(activityView: loadingSpinner)
            appRemote.userAPI?.fetchCapabilities(callback: {[weak self] (res, err) in
                guard err == nil else {
                    self?.presentAlert(title: "Error", message: err!.localizedDescription)
                    return }
                let capabilities = res as? SPTAppRemoteUserCapabilities
                if capabilities?.canPlayOnDemand == true{
                    self?.appRemote.playerAPI?.getPlayerState({ [weak self] (res, err) in
                        guard err == nil else { return }
                        // get nowPlaying
                        let playerState = res as! SPTAppRemotePlayerState
                        // save room into firestore
                        self?.saveRoom(playerState, roomName: (self?.createRoomTextField.text)!)
                        DispatchQueue.main.async {
//                            let lcnManager = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)!.locationManager
                            if let location = self?.locationManager.location{
                                DatabaseManager.shared.updateLocation(location: location)
                            }
                            self?.locationManager.requestAlwaysAuthorization()
                            self?.locationManager.startUpdatingLocation()
                            self?.hideActivityIndicator(activityView: self!.loadingSpinner)
                            self?.transitionToCreatedVC()
                        }
                    })
                }
            })
        }
    }
    
    fileprivate func setupCreateRoomCard(){
        view.addSubview(createRoomStackView)
        createRoomStackView.translatesAutoresizingMaskIntoConstraints = false
        createRoomStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        createRoomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupSegmentedControl() {
        // Segmented Control
        segmentedControl = UISegmentedControl(items: segmentedControlTabs)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .init(white: 0, alpha: 0.3)
        segmentedControl.selectedSegmentTintColor = .init(white: 0, alpha: 0.3)
        segmentedControl.setTitleTextAttributes([.font: UIFont(name: "Futura", size: 12)!, .foregroundColor: UIColor.white], for: .normal)
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        createRoomStackView.isHidden = true
    }
    
    fileprivate func setupTableView(){
//        nearbyTableView = UITableView()
        nearbyTableView.delegate = self
        nearbyTableView.dataSource = self
        nearbyTableView.register(NearbyRoomsTableViewCell.self, forCellReuseIdentifier: NearbyRoomsTableViewCell.cellIdentifier)
        nearbyTableView.backgroundColor = .none
        nearbyTableView.separatorStyle = .none
        nearbyTableView.allowsSelection = false
        nearbyTableView.isScrollEnabled = true
        // refresh control
        nearbyTableView.refreshControl = refreshControl
        refreshControl.tintColor = .init(white: 1, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Nearby Rooms", attributes: [.font: UIFont(name: "Futura", size: 12)!, .foregroundColor: UIColor.white])
        refreshControl.addTarget(self, action: #selector(getLocation), for: .valueChanged)
    }
    
    fileprivate func setupCombinedView(){
        combinedView.backgroundColor = .init(white: 0, alpha: 0.5)
//        combinedView.layer.backgroundColor = UIColor.red.cgColor
        combinedView.layer.cornerRadius = 30
        combinedView.addSubview(joinRoomStackView)
        combinedView.addSubview(nearbyTableView)
        view.addSubview(combinedView)
        combinedView.translatesAutoresizingMaskIntoConstraints = false
        combinedView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        combinedView.topAnchor.constraint(equalTo: self.segmentedControl.bottomAnchor, constant: 20).isActive = true
        combinedView.bottomAnchor.constraint(equalTo: dismissViewButton.topAnchor, constant: -20).isActive = true
        combinedView.widthAnchor.constraint(equalToConstant: view.frame.width*0.9).isActive = true
        
        
        joinRoomStackView.translatesAutoresizingMaskIntoConstraints = false
//        joinRoomStackView.widthAnchor.constraint(equalToConstant: view.frame.width*0.8).isActive = true
        joinRoomStackView.topAnchor.constraint(equalTo: combinedView.topAnchor, constant: 10).isActive = true
        joinRoomStackView.centerXAnchor.constraint(equalTo: combinedView.centerXAnchor).isActive = true
        
        
        nearbyTableView.translatesAutoresizingMaskIntoConstraints = false
//        nearbyTableView.widthAnchor.constraint(equalToConstant: combinedView.frame.width).isActive = true
        
//        nearbyTableView.heightAnchor.constraint(equalToConstant: combinedView.frame.width).isActive = true
        nearbyTableView.topAnchor.constraint(equalTo: joinRoomStackView.bottomAnchor, constant: 10).isActive = true
        nearbyTableView.leadingAnchor.constraint(equalTo: combinedView.leadingAnchor).isActive = true
        nearbyTableView.trailingAnchor.constraint(equalTo: combinedView.trailingAnchor).isActive = true
        nearbyTableView.bottomAnchor.constraint(equalTo: combinedView.bottomAnchor, constant: -30).isActive = true
    }
    
    fileprivate func setupDismissButton() {
        // cancel button
        dismissViewButton.setupTransparentButton(btnTitle: "Cancel", bgAlpha: 0.5, fontSize: 16, width: view.frame.width*0.8)
        dismissViewButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        view.addSubview(dismissViewButton)
        dismissViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dismissViewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    fileprivate func setupViews(){
        // segmented control
        setupSegmentedControl()
        
        // dismiss button
        setupDismissButton()
        
        // table view label
        nearbyRoomsLabel.setupLabel(displayText: "Nearby Rooms", fontSize: 20)
        
        // tableview
        setupTableView()
        
        // join room card
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
        joinRoomStackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        joinRoomStackView.addArrangedSubview(nearbyRoomsLabel)
        // join room card combined view
        setupCombinedView()
        
        
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
        createRoomStackView.addBackground(color: .init(white: 0, alpha: 0.5))
        createRoomStackView.layoutMargins = UIEdgeInsets(top: 30, left: 25, bottom: 30, right: 25)
        
        setupCreateRoomCard()
        
        
        
        // stackview
//        setupCombinedStackView()
//        view.addSubview(combinedStackview)
//        setupStackViewConstraints(combinedStackview)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        setupViews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    } // end of view did load
}

extension LocationViewController:UITextFieldDelegate{
    
    // shifts textgield up and down
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("textFieldDidBeginEditing")
//        if textField == createRoomTextField{
//            UIView.animate(withDuration: 0.3) {
//                self.view.frame.origin.y = -(self.view.frame.height * 0.3)
//            }
//        }
//    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("textFieldDidEndEditing")
//        UIView.animate(withDuration: 0.2) {
//            self.view.frame.origin.y = 0
//        }
//    }
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

extension LocationViewController: UITableViewDelegate{
    
}

extension LocationViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NearbyRoomsTableViewCell.cellIdentifier, for: indexPath) as! NearbyRoomsTableViewCell
        
//        cell.roomDetails = NearbyRoomsViewModel(name: "Test", auxCode: "123", numberOfUsers: 123, distance: 1200)
        cell.roomDetails = nearbyRoomsViewModel[indexPath.row]
        cell.joinButton.tag = indexPath.row
        cell.joinButton.addTarget(self, action: #selector(cellJoinRoomTapped), for: .touchUpInside)
        cell.contentView.isUserInteractionEnabled = false
//        cell.textLabel?.text = "hello"
//        cell.textLabel?.textColor = .white
//        cell.backgroundColor = .init(white: 0, alpha: 0.2)
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyRoomsViewModel.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

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
