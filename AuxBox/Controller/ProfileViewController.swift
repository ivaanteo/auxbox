//
//  ProfileViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 27/4/21.
//

import UIKit
import Firebase
import SafariServices
import FBSDKLoginKit

class ProfileViewController:UIViewController{
    
    let fbAuthManager = LoginManager()
    
    // Dimensions
    private var profilePictureSize: CGFloat { return view.frame.width * 0.5 }
    private var buttonWidth: CGFloat { return view.frame.width * 0.7 }
    private var buttonHeight: CGFloat { return 60 }
    
    // Cache
    let cache = SpotifyAuthManager.shared.cache
    
    // Views
    let logoutButton = NextButton()
    let connectSpotifyButton = NextButton()
    let profilePictureView = UIImageView()
    let stackView = UIStackView()
    
    let nameLabel = UILabel()
    let profileContainerView = UIView()
    let editProfileButton = UILabel()
    let creditsLabel = UILabel()
    let detailsView = UIView()
    
    var userDetails: UserDetails?{
        didSet{
            if let imageURL = userDetails!.profilePictureURL{
                print("imageURL \(imageURL)")
                let cacheKey = NSString(string: imageURL)
                if let img = cache.object(forKey: cacheKey){
                    DispatchQueue.main.async {
                        self.profilePictureView.image = img
                    }
                }
                DispatchQueue.main.async {
                    self.nameLabel.text = self.userDetails!.name
                    self.creditsLabel.text = "\(self.userDetails!.credits)"
                }
            }
        }
    }
    
    
    //    let safariVC = SFSafariViewController()
    
    @objc func logoutTapped(sender: UIButton!) {
        // ask if you're sure want to do this using uialert
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        showLoginPage()
    }
    
    @objc func connectSpotifyTapped(sender: UIButton!) {
        guard let url = URL(string: "\(SpotifyAPI.accountURL)authorize?client_id=\(SpotifyAPI.clientID)&response_type=code&redirect_uri=\(SpotifyAPI.redirectURI)&scope=\(HeaderField.scope)") else {
            print("error, failed to authorize spotify")
            return
        }
        // i dont want to present safari VC  when you have connected already
        // check whether there's a userdefaults saved
        // if there is, do nothing, or grey out the button
        // if there isnt then present safari vc
        presentSafariVC(with: url)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "bgColour")
//        setupNextButton(logoutButton, "Log Out")
        logoutButton.setupNextButton(title: "Log Out", fontSize: 16, width: buttonWidth, height: buttonHeight)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(logoutButton)
//        logoutButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
//        logoutButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        
//        setupNextButton(connectSpotifyButton, "Connect Spotify")
        connectSpotifyButton.setupNextButton(title: "Connect Spotify", fontSize: 16, width: buttonWidth, height: buttonHeight)
        
        connectSpotifyButton.addTarget(self, action: #selector(connectSpotifyTapped), for: .touchUpInside)
        connectSpotifyButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(connectSpotifyButton)
//        connectSpotifyButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
//        connectSpotifyButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -70).isActive = true
        
        
        
//        profilePictureView.image = UIImage(systemName: "person")
        
//        fetchUserData()
//        profilePictureView.frame = CGRect(x: 0, y: 0, width: profilePictureSize, height: profilePictureSize)
        profilePictureView.frame.size = CGSize(width: profilePictureSize, height: profilePictureSize)
//        frame = CGRect(origin: view.center, size: CGSize(width: profilePictureSize, height: profilePictureSize))
        profilePictureView.tintColor = UIColor(named: K.Colours.orange)
        profilePictureView.layer.cornerRadius = CGFloat(profilePictureSize) / 2
        profilePictureView.addCircleGradientBorder(lineWidth: 10)
        profilePictureView.contentMode = .scaleAspectFit
        //        profilePictureView.layer.masksToBounds = true
        
        profilePictureView.clipsToBounds = true
//        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        
//        view.addSubview(profilePictureView)
        profileContainerView.addSubview(profilePictureView)
        profileContainerView.translatesAutoresizingMaskIntoConstraints = false
        profileContainerView.widthAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
        profileContainerView.heightAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
        
        nameLabel.setupLabel(displayText: "", fontSize: 24, overrideText: false)
        editProfileButton.setupLabel(displayText: "Edit Profile", fontSize: 16, textColour: UIColor(named: K.Colours.offWhite)!)
        creditsLabel.setupLabel(displayText: "", fontSize: 16, textColour: UIColor(named: K.Colours.offWhite)!, overrideText: false)
        
        setupDetailsView()
        
        
        setupStackView()
        setupStackViewConstraints()
        
//        profilePictureView.widthAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
//        profilePictureView.heightAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
//        profilePictureView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
//        profilePictureView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    fileprivate func setupDetailsView(){
        detailsView.addSubview(nameLabel)
        detailsView.addSubview(editProfileButton)
        detailsView.addSubview(creditsLabel)
        
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        creditsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.topAnchor.constraint(equalTo: detailsView.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: editProfileButton.topAnchor).isActive = true
        
//        nameLabel.trailingAnchor.constraint(equalTo: creditsLabel.leadingAnchor).isActive = true
        
        editProfileButton.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor).isActive = true
        editProfileButton.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor).isActive = true
        
        creditsLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor).isActive = true
        creditsLabel.centerYAnchor.constraint(equalTo: detailsView.centerYAnchor).isActive = true
        detailsView.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
    }
    
    fileprivate func setupStackView(){
        stackView.axis = .vertical
        stackView.alignment = .center
//        stackView.distribution = .equalCentering
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.addArrangedSubview(profileContainerView)
        stackView.addArrangedSubview(detailsView)
        stackView.addArrangedSubview(connectSpotifyButton)
        stackView.addArrangedSubview(logoutButton)
        view.addSubview(stackView)
    }
    
    fileprivate func setupStackViewConstraints(){
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    
    fileprivate func setupNextButton(_ nextButton: NextButton, _ txt: String) {
        nextButton.setTitle(txt, for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "Futura", size: 16)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func showLoginPage(){
        DispatchQueue.main.async {
            let navController = UINavigationController(rootViewController: LoginViewController())
            //            let loginVC = LoginViewController()
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    // Spotify Connect
    private func presentSafariVC(with url: URL)
    {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor  = UIColor(named: K.Colours.orange)
        safariVC.preferredBarTintColor      = .white
        safariVC.delegate                   = self
        safariVC.modalPresentationStyle = .currentContext
        present(safariVC, animated: true)
    }
    
    func authorizeFirstTimeUser(with authCode: String)
    {
        // if can't get request token --> auth user
        // get token from the URL: you might need to change your index here
        //        let index = url.index(url.startIndex, offsetBy: 33)
        //        let token = url.suffix(from: index)
        //        print("token:", token)
        
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
    
    
}

extension ProfileViewController:SFSafariViewControllerDelegate{
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        let currentURL = URL.absoluteString
        if currentURL.contains("\(SpotifyAPI.redirectURL)?code="){
            // check if theres a refresh token
            if PersistenceManager.retrieveRefreshToken() == "" {
                // no refresh token, first time opening app
                // means you gotta get an ACCESS TOKEN, rather than a new refresh token
                let endpoint = String(currentURL.split(separator: "=")[1])
                self.authorizeFirstTimeUser(with: endpoint)
                
                // create randomised auxcode and check it doesnt exist in db
//                let auxCode = DatabaseManager.shared.getVerifiedAuxCode()
                // save into database
//                DatabaseManager.shared.saveAuxCode(user: Auth.auth().currentUser!, auxCode: auxCode)
                
            } else {
                // there's a refresh token saved in userdefaults
                // getRefreshToken will save it as well
                SpotifyAuthManager.shared.getRefreshToken() { results in
                    // results means the completion handler "completed"
                    guard let refreshToken = results else {
                        print("failed to get refresh token")
                        return
                    }
                    print("access token: ", PersistenceManager.retrieveAccessToken())
                    print("refresh token: ", refreshToken)
                    // cache this token here
                    // dismiss safari when done
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
}

