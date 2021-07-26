//
//  HomeScreenViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 26/4/21.
//

import UIKit
import Firebase
import StoreKit
import CoreLocation
import FBSDKLoginKit

class HomeViewController:UIViewController{
    
    // Auth Handler
    var handle:AuthStateDidChangeListenerHandle?
    //    var lastAccessTokenTime: Date?
    //    private var requestToken: RequestToken?
    
    // View Controllers
    let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    let locationVC = LocationViewController()
    let npVC = NowPlayingViewController()
    lazy var navLocVC: UINavigationController = {
        let navVc = UINavigationController(rootViewController: locationVC)
        navVc.modalPresentationStyle = .fullScreen
        return navVc
    }()
    
    // Views
    let searchBar = UISearchBar()
    let profileButton = UIButton()
    let locationButton = UIButton()
    let stackView   = UIStackView()
    let locationLabel = UILabel()
    let nowPlayingButton = NextButton()
    let nowPlayingSubview = NowPlayingSubview()
    private var collectionView: UICollectionView?
    private lazy var loadingSpinner = UIActivityIndicatorView()
    
    // View Model
    var playlistData = [PlaylistViewModel]()
    
    
    // Managers
    let spotifySearchManager = SpotifySearchManager()
    let locationManager = CLLocationManager()
    
    var didBuildHomeVC = false
    
    
    
    // MARK: - Spotify Variables
    
    private var playerState: SPTAppRemotePlayerState?
    var isConnected = false
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.presentAlert(title: "Oops, something went wrong", message: error.localizedDescription)
                }
            }
        }
    }
    
    var appRemote: SPTAppRemote? {
        get {
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
        }
    }
    
    // MARK: - Alerts
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func reconnectToSpotifyAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Reconnect to Spotify", style: UIAlertAction.Style.default, handler: { (action) in
            self.appRemote?.connect()
            //            if self.appRemote?.authorizeAndPlayURI("") == false {
            //                // The Spotify app is not installed, present the user with an App Store page
            //                self.showAppStoreInstall()
            //            }else{print("could connect to spotify")}
        }))
        alert.addAction(UIAlertAction(title: "End Session", style: UIAlertAction.Style.default, handler: { (action) in
            print("clicked end session")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - SPOTIFY ACTIONS
    
    private func playTrackWithIdentifier(_ identifier: String) {
        appRemote?.playerAPI?.play(identifier, callback: defaultCallback)
    }
    
    func subscribeToPlayerState() {
        //        guard (!subscribedToPlayerState) else { return }
        appRemote?.playerAPI?.delegate = self
        appRemote?.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            //            self.subscribedToPlayerState = true
            //            self.updatePlayerStateSubscriptionButtonState()
        }
    }
    
    func unsubscribeFromPlayerState() {
        //        guard (subscribedToPlayerState) else { return }
        appRemote?.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { print("error unsubscribing"); return }
            //            self.subscribedToPlayerState = false
            //            self.updatePlayerStateSubscriptionButtonState()
        }
    }
    
    private func getPlayerState() {
        appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            //            self.playerState = playerState
            //first load?
            DispatchQueue.main.async {
                self.nowPlayingButton.titleLabel?.text = playerState.track.name
                self.reloadInputViews()
            }
        }
    }
    
    
    
    // MARK: - Button Actions
    
    //    @objc func profileTapped(sender: UIBarButtonItem){
    //        let profileVC = ProfileViewController()
    //        profileVC.userDetails = DatabaseManager.shared.user
    //        navigationController?.pushViewController(profileVC, animated: true)
    //    }
    
    @objc func locationTapped(sender: UIBarButtonItem){
        if let roomName = DatabaseManager.shared.roomDetails?.roomName{
            guard let auxCode = DatabaseManager.shared.user?.auxCode else {return}
            guard let connectedTo = DatabaseManager.shared.user?.joinedRoom else {return}
            if auxCode == connectedTo{
                let createdVC = CreatedViewController()
                createdVC.roomNameDesc = roomName
                createdVC.modalPresentationStyle = .fullScreen
                present(createdVC, animated: true, completion: nil)
            }else{
                let joinedRoomVC = JoinedRoomViewController()
                joinedRoomVC.auxCodeDesc = connectedTo
                joinedRoomVC.roomNameDesc = roomName
                joinedRoomVC.modalPresentationStyle = .fullScreen
                present(joinedRoomVC, animated: true, completion: nil)
            }
        }else{
            //            locationManager.requestLocation()
            navLocVC.popToRootViewController(animated: true)
            present(navLocVC, animated: true, completion: nil)
        }
    }
    @objc func nowPlayingTapped(sender: UIButton){
        
        //        npVC.song = SongDetails(songName: "No Role Modelz", artist: "J. Cole", image: "https://i.scdn.co/image/ab67616d0000b2736aca031ccc27d2e4dd829d14", uri: "")
        //        npVC.roomName = "Test Room"
        let dimLayer = CALayer()
        dimLayer.backgroundColor = .init(gray: 0, alpha: 0.5)
        nowPlayingSubview.layer.insertSublayer(dimLayer, at: 0)
        present(npVC, animated: true) {
            self.nowPlayingSubview.layer.removeFromSuperlayer()
        }
    }
    
    @objc func refresh(_ sender: AnyObject){
        print("refreshed")
    }
    
    @objc func performSearch(_ vc: SearchResultsViewController) {
        guard let searchText = searchController.searchBar.text else {return}
        if searchText != ""{
            //            requestToken = spotifySearchManager.retrieveSearchResults(query: searchText, type: "track", token: PersistenceManager.retrieveClientAccessToken()) { result in
            spotifySearchManager.retrieveSearchResults(query: searchText, type: "track", token: PersistenceManager.retrieveClientAccessToken()) { result in
                switch result {
                case .success(let songData):
                    vc.songData = songData
                    // check if songData is empty
                    // if it is, show an empty view telling them about the error
                    if (songData.isEmpty){
                        DispatchQueue.main.async {
                            vc.errorLabel = UILabel()
                            vc.errorLabel!.text = "Oops, we couldn't find anything matching '\(searchText)'!"
                            vc.tableView.backgroundView = vc.errorLabel
                            vc.tableView.separatorStyle = .none
                            vc.hideActivityIndicator()
                            vc.tableView.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async {
                            vc.tableView.backgroundView = .none
                            vc.tableView.separatorStyle = .singleLine
                            vc.hideActivityIndicator()
                            vc.tableView.reloadData()
                        }
                    }
                case .failure(URLError.cancelled):
                    // Request was cancelled, no need to do any handling
                    break
                case .failure(let error):
                    // show them empty screen with error message, eg. no internet connection
                    vc.songData = []
                    DispatchQueue.main.async {
                        vc.errorLabel = UILabel()
                        vc.errorLabel!.text = "Sorry, something went wrong! \(error.localizedDescription)"
                        vc.tableView.backgroundView = vc.errorLabel
                        vc.tableView.separatorStyle = .none
                        vc.hideActivityIndicator()
                        vc.tableView.reloadData()
                    }
                }
            }
        }else{
            vc.songData = []
            DispatchQueue.main.async{
                vc.hideActivityIndicator()
                vc.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: - App Lifecycle
    fileprivate func updateRoomUI(room: RoomModel) {
        DispatchQueue.main.async {
            //            self.locationButton.titleLabel?.text = room.roomName
            self.title = (DatabaseManager.shared.roomDetails?.roomName == nil) ? "Home" : DatabaseManager.shared.roomDetails?.roomName
            self.nowPlayingSubview.song = SongViewModel(songName: room.nowPlaying.songName,
                                                        artist: room.nowPlaying.artist,
                                                        image: room.nowPlaying.image, uri:"")
            self.nowPlayingSubview.songsInQueue = room.currentQueue.count + room.normalQueue.count
            self.collectionView?.reloadData()
            // change to reloadInputViews??
        }
    }
    
    fileprivate func fetchJoinedRoom(_ auxCode: String) {
        DatabaseManager.shared.fetchData(collection: K.FStore.roomsCollection,
                                         document: auxCode,
                                         type: RoomModel.self) { result in
            switch result{
            case .success(let room):
                DatabaseManager.shared.roomDetails = room
                self.updateRoomUI(room: room)
                if auxCode == DatabaseManager.shared.user?.auxCode{
                    if self.appRemote?.authorizeAndPlayURI("") == false {
                        // The Spotify app is not installed, present the user with an App Store page
                        self.showAppStoreInstall()
                    }else{print("spotify downloaded")}
                }
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.rawValue)
            }
        }
    }
    
    fileprivate func listenToDatabase(_ auxCode: String, withQueue: Bool) {
        DatabaseManager.shared.addDatabaseListener(auxCode: auxCode) { (room) in
            // if room still exists
            if let safeRoom = room{
                DatabaseManager.shared.roomDetails = safeRoom
                // Queue Songs
                if withQueue{
                    // prevents guests from queueing
                    let queueList = safeRoom.toQueue
                    if queueList.count > 0{
                        // premium queue
                        SpotifyAuthManager.shared.queueSongs(with: queueList)
                        DatabaseManager.shared.didQueueSongs(queueList:queueList)
                    }
                    else if safeRoom.normalQueue.count > 0 && safeRoom.currentQueue.count == 0{
                        // no songs in premium queue,
                        // check if theres a song in normal queue
                        // and no songs in current queue
                        let songToNormalQueue = safeRoom.normalQueue[0]
                        SpotifyAuthManager.shared.normalQueueSong(uri: songToNormalQueue)
                        DatabaseManager.shared.didNormalQueueSong(uri: songToNormalQueue)
                    }
                }
                // update nowPlaying
                self.collectionView?.refreshControl?.endRefreshing()
                self.updateRoomUI(room: safeRoom)
                self.npVC.updateUI()
                print("is updating room ui")
            }else{
                // room does not exist anymore
                DatabaseManager.shared.deleteJoinedRoom()
                DatabaseManager.shared.removeDatabaseListener()
                self.resetNowPlayingUI()
                self.npVC.updateUI()
            }
        }
    }
    
//    private func updateProfileImg(userDetails: UserDetails) {
//        guard let photoURL = userDetails.profilePictureURL else {return}
//        if photoURL.contains("facebook"){
//            // check if user image is from facebook. if so, make graph request
//            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480)"])
//            graphRequest.start(completionHandler: { (connection, result, error) in
//                if error != nil {
//                    self.hideActivityIndicator(activityView: self.loadingSpinner)
//                    print("Error",error!.localizedDescription)
//                }
//                else{
//                    let field = result! as? [String:Any]
//                    if let imageURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
//                        SpotifyAuthManager.shared.downloadImage(from: imageURL, defaultImage: UIImage(systemName: "person")!, key: photoURL) { (img) in
//                            DispatchQueue.main.async {
//                                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
//                                imgView.image = img
//                                imgView.layer.cornerRadius = imgView.frame.height / 2
//                                imgView.addCircleGradientBorder()
//                                self.navigationItem.rightBarButtonItem?.customView?.subviews[0].removeFromSuperview()
//                                self.navigationItem.rightBarButtonItem?.customView?.addSubview(imgView)
//                                //                                self.navigationItem.rightBarButtonItem?.customView?.subviews[0]
//                                //                                self.hideActivityIndicator(activityView: self.loadingSpinner)
//                            }
//                        }
//                    }
//                    self.hideActivityIndicator(activityView: self.loadingSpinner)
//                }
//            })
//        }else{
//            SpotifyAuthManager.shared.downloadImage(from: photoURL, defaultImage: UIImage(systemName: "person")!){ (img) in
//                DispatchQueue.main.async {
//                    self.profileButton.imageView?.image = img
//                }
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("home view will appear")
        // LISTEN FOR AUTHSTATE
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            //            guard let user = Auth.auth().currentUser else {return}
            guard let user = user else { return }
            // fetch user data, save if needed
            DatabaseManager.shared.saveUser(user: user) { (userDetails) in
                // update profile pic
                guard let userDetails = userDetails else { return }
                //                self.updateProfileImg(userDetails: userDetails)
                // the intent is to use this closure to determine if there's a joined room on Log In
                guard let auxCode = userDetails.joinedRoom else {
                    self.resetNowPlayingUI()
                    return} // no joined Room, can reset UI
                
                guard userDetails.joinedRoom != "" else{
                    // this case probably won't happen, see if can remove
                    self.resetNowPlayingUI()
                    return
                }
                
                let isHost = (auxCode == DatabaseManager.shared.user?.auxCode)
                // listen for nowPlaying updates here, though toQueue updates will also be given
                self.listenToDatabase(auxCode, withQueue: isHost)
                
                // connect spotify
                if isHost{
                    // get location in case
                    if let location = self.locationManager.location{
                        DatabaseManager.shared.updateLocation(location: location)
                    }
                    self.locationManager.requestAlwaysAuthorization()
                    self.locationManager.startUpdatingLocation()
                    
                    if let isSpotifyConnected = self.appRemote?.isConnected{
                        print("Spotify connected: \(isSpotifyConnected)")
                        if !isSpotifyConnected{
                            // should work for first time app only
                            if self.appRemote?.authorizeAndPlayURI("") == false {
                                // The Spotify app is not installed, present the user with an App Store page
                                self.showAppStoreInstall()
                            }else{print("could connect to spotify")}
                        }
                    }
                }
            }
        })
        //        self.updateHomeUI(userUID: uid)
        //        self.reloadInputViews()
        //        print("connected to auxCode: \(DatabaseManager.connectedToAuxCode)")
        //        if DatabaseManager.connectedToAuxCode != ""{
        //
        //            listenToDatabase()
        //        }else{
        //            // on initial load, if no connectToAux
        //            // should reset only if nowPlayingUI is not this current state
        //            self.resetNowPlayingUI()
        //        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        DatabaseManager.shared.removeDatabaseListener()
    }
    
    override func viewDidLoad() {
        checkSigninStatus()
    }
    
    func checkSigninStatus(){
        if Auth.auth().currentUser == nil{
            // not logged in
            showLoginPage()
        }else if !PersistenceManager.emailLoginAndVerified() || Auth.auth().currentUser?.displayName == nil{
            showLoginPage()
        }
        else{
            //logged in, build current view
            buildHomeView()
        }
    }
    
    fileprivate func resetNowPlayingUI() {
        DispatchQueue.main.async {
            self.title = (DatabaseManager.shared.roomDetails?.roomName == nil) ? "Home" : DatabaseManager.shared.roomDetails?.roomName
            self.nowPlayingSubview.songsInQueue = 0
            self.nowPlayingSubview.song = SongViewModel(songName: "Not Connected",
                                                        artist: "Hit the connect button to get started!",
                                                        image: "", uri: "")
            self.collectionView?.reloadData()
        }
    }
    
    
    func updateHomeUI(userUID:String) {
        // can refactor such that you only reload input views
        
        // Check if user is connected to room
        DatabaseManager.shared.fetchData(collection: K.FStore.usersCollection,
                                         document: userUID,
                                         type: UserDetails.self) { (res) in
            switch res{
            case .success(let user):
                guard let auxCode = user.joinedRoom else {return} // returns if no connected room, we can update ui
                //                DatabaseManager.connectedToAuxCode = auxCode
                DatabaseManager.shared.user?.joinedRoom = auxCode
                DatabaseManager.shared.fetchData(collection: K.FStore.roomsCollection,
                                                 document: auxCode,
                                                 type: RoomModel.self) { result in
                    switch result{
                    case .success(let room):
                        DatabaseManager.shared.roomDetails = room
                        // here, ui is being updated. But viewWillAppear also takes care of this
                        //                        DispatchQueue.main.async {
                        //                            self.locationButton.titleLabel?.text = room.roomName
                        //                            self.nowPlayingSubview.song = SongDetails(songName: room.nowPlaying.songName,
                        //                                                                      artist: room.nowPlaying.artist,
                        //                                                                      image: room.nowPlaying.image, uri:"")
                        //                            self.nowPlayingSubview.songsInQueue = room.currentQueue.count
                        //                        }
                        if auxCode == DatabaseManager.shared.user?.auxCode{
                            if self.appRemote?.authorizeAndPlayURI("") == false {
                                // The Spotify app is not installed, present the user with an App Store page
                                self.showAppStoreInstall()
                            }else{print("could connect to spotify")}
                        }
                    case .failure(let error):
                        self.presentAlert(title: "Error", message: error.rawValue)
                    }
                }
            case .failure(let error):
                self.presentAlert(title: "Oops, something went wrong", message: error.rawValue)
            //                self.resetNowPlayingUI()
            }
        }
    }
    
    func buildHomeView(){
        if !didBuildHomeVC{
            didBuildHomeVC = true
            view.backgroundColor = UIColor(named: K.Colours.bgColour)
            
            //            setupSearchBar()
            //            setupProfileButton(profileButton)
            setupLocationButton(locationButton)
            navigationItem.backButtonTitle = ""
            //            navigationController?.navigationItem.hidesSearchBarWhenScrolling = false
            //        setupNavigationRightBarButton()
            
            //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            //        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
            //        view.addSubview(refreshControl)
            
            //        setupNavigationTitle()
            //        navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationTapped)))
            
            // set self as searchcontroller delegate
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 20
            let size = CGSize(width:(view.frame.width - 60)/2, height: (view.frame.width+60)/2)
            layout.itemSize = size
            
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            guard let collectionView = collectionView else { return }
            collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
            collectionView.register(NowPlayingCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NowPlayingCollectionReusableView.cellId)
            collectionView.backgroundColor = .clear
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.showsVerticalScrollIndicator = false
            
            //            searchController.delegate = self
            self.view.addSubview(collectionView)
            setupCollectionViewConstraints(collectionView)
            // must add activity indicator after collection view to prevent bugs
            showActivityIndicator(activityView: loadingSpinner)
            
            SpotifyAuthManager.shared.getFeaturedPlaylists(numberOfPlaylists: 20) { (res) in
                switch res{
                case .success(let playlistDetails):
                    DispatchQueue.main.async{
                        self.playlistData = playlistDetails
                        self.loadingSpinner.stopAnimating()
                        self.collectionView?.reloadData()
                        print("fetched playlist success")
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Error", message: "Failed to fetch featured playlists")
                        self.loadingSpinner.stopAnimating()
                        print("fetched playlist failed")
                    }
                }
            }
        }
    }
    
    fileprivate func setupNavigationTitle(){
        // outdated code
        locationLabel.setupLabel(displayText: "Test", fontSize: 26)
        //        locationLabel.text = (DatabaseManager.roomDetails?.roomName == nil) ? "Unplugged" : DatabaseManager.roomDetails?.roomName
        //        navigationController?.navigationBar.
        navigationItem.titleView = locationLabel
        //        navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
    }
    
    //
    //    fileprivate func setupNavigationRightBarButton(customView: UIView){
    //        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
    //        navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped)))
    //    }
    fileprivate func setupNavigationLeftBarButton(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: locationButton)
        navigationItem.leftBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationTapped)))
    }
    
    //    fileprivate func setupProfileButton(_ profileButton: UIButton) {
    ////        let image = UIImage(named: "animoji")
    ////        let config = UIImage.SymbolConfiguration(pointSize: 10)
    ////        let image = UIImage(systemName: "person", withConfiguration: config)
    //        let image = UIImage(systemName: "person")
    //        let frame = CGRect(x: 0, y: 0, width: 34, height: 34)
    //        let customView = UIView(frame: frame)
    //        let imgView = UIImageView(image: image)
    //        imgView.frame = frame
    ////        imgView.layer.cornerRadius = imgView.frame.height*0.5
    ////        imgView.layer.masksToBounds = true
    //        customView.addSubview(imgView)
    //        setupNavigationRightBarButton(customView: customView)
    //    }
    
    
    //    fileprivate func setupSearchBar(){
    //        searchController.searchResultsUpdater = self
    //        navigationItem.searchController = searchController
    //        navigationItem.searchController?.searchBar.placeholder = "What's next, DJ?"
    //        navigationItem.searchController?.searchBar.searchTextField.font = UIFont(name: "Futura", size: 12)
    //        navigationItem.searchController?.searchBar.searchTextField.textColor = UIColor(named: K.Colours.textColour)
    //        navigationItem.searchController?.searchBar.searchTextField.leftView?.tintColor = UIColor(named: K.Colours.textColour)
    //        navigationItem.searchController?.searchBar.searchTextField.backgroundColor = .white
    //        navigationItem.hidesSearchBarWhenScrolling = false
    //    }
    fileprivate func setupLocationButton(_ locationButton: UIButton){
        //        locationButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        //        locationButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        //        locationButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        locationButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        // always nil because initialise before data can come in
        //        locationButton.setTitle((DatabaseManager.roomDetails?.roomName == nil) ? "Connect" : DatabaseManager.roomDetails?.roomName, for: .normal)
        locationButton.setTitle("Connect", for: .normal)
        locationButton.titleLabel?.font = UIFont(name: "Futura", size: 14)
        locationButton.titleLabel?.textColor = UIColor(named: K.Colours.offWhite)
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        locationButton.sizeToFit()
        locationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        locationButton.titleLabel?.minimumScaleFactor = 0.2
        locationButton.titleLabel?.lineBreakMode = .byTruncatingTail
        setupNavigationLeftBarButton()
    }
    fileprivate func setupNowPlayingButton(_ nextButton: NextButton) {
        nextButton.setTitle("Now Playing", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "Futura", size: 16)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.widthAnchor.constraint(equalToConstant: view.frame.width-40).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: view.frame.height/5).isActive = true
    }
//    fileprivate func setupStackView(_ stackView: UIStackView, _ btn: UIView, _ collectionView: UICollectionView) {
//        stackView.axis  = NSLayoutConstraint.Axis.vertical
//        stackView.distribution  = UIStackView.Distribution.equalSpacing
//        stackView.alignment = UIStackView.Alignment.center
//        stackView.spacing   = 16.0
//        stackView.addArrangedSubview(btn)
//        stackView.addArrangedSubview(collectionView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//    }
//
//    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
//        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
//    }
    
    fileprivate func setupCollectionViewConstraints(_ colView: UICollectionView) {
        //        view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //        colView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        colView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        colView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        colView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        colView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        colView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
}
//
//extension HomeViewController:UISearchResultsUpdating{
//
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let vc = searchController.searchResultsController as? SearchResultsViewController else {return}
//        vc.showActivityIndicator()
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: vc)
//        perform(#selector(self.performSearch), with: vc, afterDelay: 0.5)
//    }
//}
//
//extension HomeViewController:UISearchControllerDelegate{
//    func didPresentSearchController(_ searchController: UISearchController) {
//        // retrieve access token from user defaults and use it
//        SpotifyAuthManager.shared.getClientAccessToken(completed: nil)
//    }
//}

extension HomeViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NowPlayingCollectionReusableView.cellId, for: indexPath) as! NowPlayingCollectionReusableView
        //        header.song = DatabaseManager.roomDetails?.nowPlaying
        //        header.songsInQueue = DatabaseManager.roomDetails?.currentQueue.count ?? 0
        header.nowPlayingSubView.song = DatabaseManager.shared.roomDetails?.nowPlaying ??
            SongViewModel(songName: "Not Connected",
                          artist: "Hit the connect button to get started!",
                          image: "", uri: "")
        let curQueueLength = DatabaseManager.shared.roomDetails?.currentQueue.count ?? 0
        let normalQueueLength = DatabaseManager.shared.roomDetails?.normalQueue.count ?? 0
        header.nowPlayingSubView.songsInQueue = curQueueLength + normalQueueLength
        //        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nowPlayingTapped)))
        header.nowPlayingSubView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nowPlayingTapped)))
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlistViewController = PlaylistViewController()
        SpotifyAuthManager.shared.downloadImage(from: playlistData[indexPath.row].imgURL ?? "") { (image) in
            playlistViewController.playlistCoverImage = image
            playlistViewController.playlistTitle = self.playlistData[indexPath.row].name
            playlistViewController.playlistID = self.playlistData[indexPath.row].playlistID
        }
        SpotifyAuthManager.shared.getPlaylistDetails(playlistID: playlistData[indexPath.row].playlistID, market: "SG") { (res) in
            switch res{
            case .success(let songDetails):
                playlistViewController.playlistTracks = songDetails
                DispatchQueue.main.async {
                    playlistViewController.playlistTableView.reloadData()
                }
            case .failure(let failure):
                self.presentAlert(title: "Error", message: failure.localizedDescription)
                return
            }
        }
        self.navigationController?.pushViewController(playlistViewController, animated: true)
    }
}

extension HomeViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width * 0.9,
                      height: view.frame.width*0.50)
    }
}

extension HomeViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.playlistData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        //        cell.playlist = Playlist(name: "Chill Hits", imageURL: "https://i.scdn.co/image/ab67706f00000003cf8e264c6a92e245402ecb7a")
        guard let imgURL = playlistData[indexPath.row].imgURL else { return cell}
        let representedIdentifier = playlistData[indexPath.row].playlistID
        cell.representedIdentifier = representedIdentifier
        
        SpotifyAuthManager.shared.downloadImage(from: imgURL) { (image) in
            DispatchQueue.main.async {
                if cell.representedIdentifier == representedIdentifier{
                    cell.playlistImageView.image = image ?? UIImage(systemName: "music.note")
                    cell.playlistTitleLabel.text = self.playlistData[indexPath.row].name
                }
            }
        }
        
        return cell
    }
}

// MARK: - SPOTIFY EXTENSIONS


// MARK: - SPTAppRemotePlayerStateDelegate
extension HomeViewController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("playerstate did change")
        self.playerState = playerState
        let trackUri = playerState.track.uri
        // now we check if it exists
        guard var room = DatabaseManager.shared.roomDetails else { return }
        
        // check if song has changed
        if room.nowPlaying.uri != trackUri{
            // immediately set this to prevent multiple calls
            room.nowPlaying.uri = trackUri
            SpotifyAuthManager.shared.getSongDetails(trackURI: trackUri) { result in
                // update local variable first
                switch result{
                case .success(let currentTrack):
                    room.nowPlaying = currentTrack
                    if room.currentQueue.first == trackUri{
                        // get the count
                        // if count == 1 here, meaning that its bout to be 0,
                        
                        // we wanna queue the song from normal queue and remove it
                        if room.normalQueue.count > 0 && room.currentQueue.count == 1 {
                            let songToNormalQueue = room.normalQueue[0]
                            SpotifyAuthManager.shared.normalQueueSong(uri: songToNormalQueue)
                            room.normalQueue.remove(at: 0)
                            room.currentQueue.append(songToNormalQueue)
                        }
                        room.currentQueue.remove(at: 0)
                    }
                    //this updates both global variable and database
                    //                        DatabaseManager.shared.startActiveRoom(room: room)
                    DatabaseManager.shared.updateEntireRoom(room: room)
                    //                        DatabaseManager.shared.updateRoomNowPlaying(nowPlaying: currentTrack)
                    DatabaseManager.shared.roomDetails = room
                case .failure(let error):
                    self.presentAlert(title: "Error", message: error.rawValue)
                }
            }
        }
    }
}
// MARK: - SPTAppRemoteUserAPIDelegate
extension HomeViewController: SPTAppRemoteUserAPIDelegate {
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
    }
}

// MARK: SKStoreProductViewControllerDelegate
extension HomeViewController: SKStoreProductViewControllerDelegate {
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
extension HomeViewController : SPTAppRemoteDelegate{
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("DIDESTABLISHCONNECTION!!!!")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed w error")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("diconnected w error")
    }
}

extension HomeViewController : CLLocationManagerDelegate{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let allowsBackground = manager.allowsBackgroundLocationUpdates
        print("allows background: \(allowsBackground)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager did fail with error", error.localizedDescription)
    }
    
}
