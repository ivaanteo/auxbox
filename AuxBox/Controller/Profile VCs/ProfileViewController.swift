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
    
    //Buttons
    let logoutButton = NextButton()
    let purchaseCoinsButton = NextButton()
    let transactionsButton = NextButton()
    
    let profilePictureView = UIImageView()
    let stackView = UIStackView()
    
    let nameLabel = UILabel()
    let profileContainerView = UIView()
    let editProfileButton = UIButton()
    let creditsLabel = UILabel()
    let detailsView = UIView()
    
    private var loadingSpinner = UIActivityIndicatorView()
    
    @objc func editProfileTapped(){
        let editProfileVC = SetupProfileViewController()
        editProfileVC.isSettingUp = false
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @objc func logoutTapped(sender: UIButton!) {
        // ask if you're sure want to do this using uialert
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            return
        }
        
        // remove local storage is auth
        PersistenceManager.setEmailLoginVerified(loggedIn: false)
        DatabaseManager.shared.user = nil
        DatabaseManager.shared.roomDetails = nil
        showLoginPage()
    }
    
    @objc func purchaseCoinsButtonTapped(sender: UIButton!){
        let layout = UICollectionViewFlowLayout()
        let purchaseCoinsViewController = PurchaseCoinsCollectionViewController(collectionViewLayout: layout)
        purchaseCoinsViewController.onDismiss = {
            guard let user = DatabaseManager.shared.user else { return }
            DispatchQueue.main.async {
                self.creditsLabel.text = "\(user.credits)"
            }
        }
//        navigationController?.pushViewController(purchaseCoinsViewController, animated: true)
        present(purchaseCoinsViewController, animated: true, completion: nil)
    }
    
    @objc func transactionsTapped(sender: UIButton!){
        let transactionsVC = TransactionsViewController()
        navigationController?.pushViewController(transactionsVC, animated: true)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "bgColour")
//        setupNextButton(logoutButton, "Log Out")
        logoutButton.setupNextButton(title: "Log Out", fontSize: 16, width: buttonWidth, height: buttonHeight)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        purchaseCoinsButton.setupNextButton(title: "Purchase Coins", fontSize: 16, width: buttonWidth, height: buttonHeight)
        purchaseCoinsButton.addTarget(self, action: #selector(purchaseCoinsButtonTapped), for: .touchUpInside)
        purchaseCoinsButton.translatesAutoresizingMaskIntoConstraints = false
        
        transactionsButton.setupNextButton(title: "Transactions", fontSize: 16, width: buttonWidth, height: buttonHeight)
        transactionsButton.addTarget(self, action: #selector(transactionsTapped), for: .touchUpInside)
        transactionsButton.translatesAutoresizingMaskIntoConstraints = false
        
//        profilePictureView.frame.size = CGSize(width: profilePictureSize, height: profilePictureSize)
//        profilePictureView.tintColor = UIColor(named: K.Colours.orange)
//        profilePictureView.layer.cornerRadius = CGFloat(profilePictureSize) / 2
//        profilePictureView.contentMode = .scaleAspectFit
//        profilePictureView.clipsToBounds = true
        profilePictureView.cropCircle(width: profilePictureSize)
        profilePictureView.addCircleGradientBorder()
        
        profileContainerView.addSubview(profilePictureView)
        profileContainerView.translatesAutoresizingMaskIntoConstraints = false
        profileContainerView.widthAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
        profileContainerView.heightAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
        
        nameLabel.setupLabel(displayText: "", fontSize: 24, overrideText: false)
//        editProfileButton.setupLabel(displayText: "Edit Profile", fontSize: 16, textColour: UIColor(named: K.Colours.offWhite)!)
        editProfileButton.setupUnderlineTextButton(btnTitle: "Edit Profile", fontSize: 16)
        editProfileButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfileTapped)))
        creditsLabel.setupLabel(displayText: "", fontSize: 16, textColour: UIColor(named: K.Colours.offWhite)!, overrideText: false)
        
        setupDetailsView()
        
        
        setupStackView()
        setupStackViewConstraints()
        
//        profilePictureView.widthAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
//        profilePictureView.heightAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
//        profilePictureView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
//        profilePictureView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
//        guard let user = DatabaseManager.shared.user else { return }
//        self.showActivityIndicator(activityView: loadingSpinner)
//        updateProfileImg(userDetails: user, profilePictureView: profilePictureView, loadingSpinner: loadingSpinner)
//        updateProfileImg(userDetails: user, )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let user = DatabaseManager.shared.user else { return }
        DispatchQueue.main.async {
            self.showActivityIndicator(activityView: self.loadingSpinner)
            self.nameLabel.text = user.name
            self.creditsLabel.text = "\(user.credits)"
            self.updateProfileImg(userDetails: user, profilePictureView: self.profilePictureView, loadingSpinner: self.loadingSpinner)
        }
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
        nameLabel.widthAnchor.constraint(equalToConstant: buttonWidth-20).isActive = true
        
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
        stackView.addArrangedSubview(purchaseCoinsButton)
        stackView.addArrangedSubview(transactionsButton)
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
    
}
