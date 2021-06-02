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
    let logoutButton = NextButton()
    let connectSpotifyButton = NextButton()
    let profilePictureView = UIImageView()
    let fbAuthManager = LoginManager()
    let profilePictureSize = 200
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
        setupNextButton(logoutButton, "Log Out")
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        setupNextButton(connectSpotifyButton, "Connect Spotify")
        connectSpotifyButton.addTarget(self, action: #selector(connectSpotifyTapped), for: .touchUpInside)
        connectSpotifyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectSpotifyButton)
        connectSpotifyButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        connectSpotifyButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -70).isActive = true
        
        
        profilePictureView.image = UIImage(systemName: "person")
        profilePictureView.tintColor = UIColor(named: K.Colours.orange)
        fetchUserData()
        
        profilePictureView.layer.cornerRadius = CGFloat(profilePictureSize) / 2
        profilePictureView.layer.borderWidth = 1
        //        profilePictureView.layer.masksToBounds = true
        profilePictureView.clipsToBounds = true
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profilePictureView)
        profilePictureView.widthAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
        profilePictureView.heightAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
        profilePictureView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        profilePictureView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profilePictureView.contentMode = .scaleAspectFit
        
        
        
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
    
    private func fetchUserData() {
//        print(Auth.auth().currentUser?.displayName)
        guard let photoURL = Auth.auth().currentUser?.photoURL else {return}
        if (photoURL.absoluteString.contains("facebook")) == true{
            // check if user image is from facebook. if so, make graph request
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480)"])
            graphRequest.start(completionHandler: { (connection, result, error) in
                if error != nil {
                    print("Error",error!.localizedDescription)
                }
                else{
                    let field = result! as? [String:Any]
                    if let imageURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        let url = URL(string: imageURL)
                        let data = NSData(contentsOf: url!)
                        let image = UIImage(data: data! as Data)
                        self.profilePictureView.image = image
                        
                        // PLEASE CACHE THE PHOTO!!
                        
                    }
                }
            })
        }else{
            // else just use normal process to fill uiimageview
            if let data = try? Data(contentsOf: photoURL){
                let image = UIImage(data:data)
                self.profilePictureView.image = image
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

