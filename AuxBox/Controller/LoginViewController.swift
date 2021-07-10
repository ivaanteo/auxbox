//
//  ViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 16/4/21.
//

import UIKit
import FBSDKLoginKit
import Firebase

// Add this to the body
class LoginViewController: UIViewController, LoginButtonDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor(named: "bgColour")
    
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 300, height: 50))
        setupButton(button)
        
        let loginButton = FBLoginButton()
        loginButton.center = view.center
//        view.addSubview(loginButton)
        loginButton.delegate = self
        
        if let token = AccessToken.current,
                !token.isExpired {
                // User is logged in, do work such as go to next view controller.
            }
        
        loginButton.permissions = ["public_profile", "email"]
    
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 16.0
        
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(loginButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    fileprivate func setupButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        // makes button have buffers at edges
        button.contentEdgeInsets =  UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.setTitleColor(.black, for: .normal)
    }
    
    
}

extension LoginViewController{
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
      if let error = error {
        print(error.localizedDescription)
        return
      }
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            let authError = error as NSError
            return
          }
        }
        
    }
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
    }
}
