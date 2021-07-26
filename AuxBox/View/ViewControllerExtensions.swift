//
//  ViewControllerExtensions.swift
//  AuxBox
//
//  Created by Ivan Teo on 6/7/21.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth

extension UIViewController{
    func showActivityIndicator(activityView: UIActivityIndicatorView, color: UIColor = .white) {
        activityView.style = .large
        activityView.color = color
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    func hideActivityIndicator(activityView: UIActivityIndicatorView){
        activityView.stopAnimating()
    }
    
    func showAlert(title: String, message: String, completed: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            if let completionHandler = completed{
                completionHandler()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureGradientBackground() {
        self.view.backgroundColor = .none
        let gradientLayer = Colors().gl
        gradientLayer?.frame = view.frame
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    func shakeView(view: UIView, highlightBorder: Bool = true){
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.3) {
            if highlightBorder{
                view.layer.borderColor = UIColor.red.cgColor
                view.layer.borderWidth = 1
            }
            view.transform = CGAffineTransform(translationX: 10, y: 0)
        }
        
        propertyAnimator.addAnimations({
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.2)
        
        propertyAnimator.addCompletion { (_) in
            view.layer.borderWidth = 0
        }
        
        propertyAnimator.startAnimation()
    }
    
    func updateProfileImg(userDetails: UserDetails, profilePictureView: UIImageView, loadingSpinner: UIActivityIndicatorView?) {
        let photoURL = userDetails.profilePictureURL ?? "defaultImg"
        if photoURL.contains("facebook"){
            // check if user image is from facebook. if so, make graph request
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480)"])
            graphRequest.start(completionHandler: { (connection, result, error) in
                if error != nil {
                    if let loadingSpinner = loadingSpinner{
                        self.hideActivityIndicator(activityView: loadingSpinner)
                    }
                    print("Error getting fb photo",error!.localizedDescription)
                }
                else{
                    print("no error w graph request")
                    let field = result! as? [String:Any]
                    if let imageURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        SpotifyAuthManager.shared.downloadImage(from: imageURL, defaultImage: UIImage(systemName: "person.circle.fill")!, key: photoURL) { (img) in
                            DispatchQueue.main.async {
                                print("made it here")
                                profilePictureView.image = img
                                if let loadingSpinner = loadingSpinner{
                                    self.hideActivityIndicator(activityView: loadingSpinner)
                                }
                            }
                        }
                    }
                    if let loadingSpinner = loadingSpinner{
                        self.hideActivityIndicator(activityView: loadingSpinner)
                    }
                }
            })
        }else{
            SpotifyAuthManager.shared.downloadImage(from: photoURL, defaultImage: UIImage(systemName: "person.circle.fill")!){ (img) in
                DispatchQueue.main.async {
                    profilePictureView.image = img
                    if let loadingSpinner = loadingSpinner{
                        self.hideActivityIndicator(activityView: loadingSpinner)
                    }
                }
            }
        }
    }
    
    func showLoginPage(){
        DispatchQueue.main.async {
            let navController = UINavigationController(rootViewController: LoginViewController())
            navController.setupCustomNavBar()
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            guard let curUser = Auth.auth().currentUser else { return }
            print("current user exists")
//            if Auth.auth().currentUser != nil{
                // there's an account but not verified
            
            if !curUser.isEmailVerified{
                Auth.auth().fetchSignInMethods(forEmail: curUser.email ?? "") { (res, err) in
                    guard err == nil else { return }
                    guard let methods = res else { return }
                    print("res \(methods)")
//                    if methods.contains("facebook.com"){
//                        print("facebook login")
//                    }else
                    if methods.contains("password"){
                        print("email login")
                        navController.pushViewController(EmailConfirmationViewController(), animated: false)
                    }
                }
            }else if curUser.displayName == nil{
                navController.pushViewController(SetupProfileViewController(), animated: false)
            }
//            }
            
            
        }
    }
}

