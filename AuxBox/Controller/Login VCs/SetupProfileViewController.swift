//
//  SetupProfileViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 15/7/21.
//

import UIKit
import Firebase

class SetupProfileViewController: UIViewController{
    // dimensions
    private var profilePictureSize: CGFloat { return view.frame.width * 0.5 }
    
    let profilePictureImageView = UIImageView()
    let profileContainerView = UIView()
    let upperStackView = UIStackView()
    let lowerStackView = UIStackView()
    
    let uploadPhotoButton = UIButton()
    
    let displayNameLabel = UILabel()
    let nameTextField = PaddedTextField()
    
    let emailLabel = UILabel()
    let emailTextField = PaddedTextField()
    let loadingSpinner = UIActivityIndicatorView()
    
    let nextButton = NextButton()
    
    let scrollView = UIScrollView()
    
    // check if set up or edit
    var isSettingUp: Bool = true{
        didSet{
            if !self.isSettingUp{
//                emailLabel.setupLabel(displayText: "Email", fontSize: 16)
//                emailTextField.setupTextField(placeholderText: "", width: view.frame.width * 0.9)
//                lowerStackView.addArrangedSubview(emailLabel)
//                lowerStackView.addArrangedSubview(emailTextField)
                title = "Edit Profile"
                fillInUserDetails()
            }
        }
    }
    
    // variables to edit
    var imgToUpload : UIImage?
    var updatedUser: UserDetails? = DatabaseManager.shared.user
    
    @objc func saveButtonTapped(sender: UIButton!){
        sender.isEnabled = false
        print("did tap")
        if isSettingUp{
            if nameTextField.text != ""{
                DispatchQueue.main.async {
                    self.showActivityIndicator(activityView: self.loadingSpinner, color: UIColor(named: K.Colours.orange)!)
                }
                // update auth
                // img to upload will be nil if no photo uploaded, will return a nil url
                DatabaseManager.shared.storeProfileImage(image: imgToUpload) { (url) in
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.nameTextField.text
                    // only add imgurl to request if there was a photo uploaded
                    if let safeUrl = url{
                        changeRequest?.photoURL = safeUrl
                    }
                    changeRequest?.commitChanges { error in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.hideActivityIndicator(activityView: self.loadingSpinner)
                                self.showAlert(title: "Error Saving Changes", message: error.localizedDescription)
                                sender.isEnabled = true
                            }
                        }
                        else{
                            // log in
                            DispatchQueue.main.async {
                                self.onLoginSuccess()
                                self.hideActivityIndicator(activityView: self.loadingSpinner)
                            }
                        }
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.shakeView(view: self.nameTextField)
                    sender.isEnabled = true
                }
            }
        }else{
            print("else block")
            DispatchQueue.main.async {
                self.showActivityIndicator(activityView: self.loadingSpinner, color: UIColor(named: K.Colours.orange)!)
            }
            // update database and auth??
            // look at what has changed, and upload those fields only
            
            // identify whether image changed by using imgToUpload
                DatabaseManager.shared.storeProfileImage(image: imgToUpload) { (url) in
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    // only add imgurl to request if there was a photo uploaded
                    var didUpdate = false
                    if let safeUrl = url{
                        changeRequest?.photoURL = safeUrl
                        self.updatedUser?.profilePictureURL = safeUrl.absoluteString
                        didUpdate = true
//                        updatedImgUrl = safeUrl.absoluteString
                    }
                    if Auth.auth().currentUser?.displayName != self.nameTextField.text && self.nameTextField.text != ""{
                        changeRequest?.displayName = self.nameTextField.text
                        self.updatedUser?.name = self.nameTextField.text
                        didUpdate = true
//                        updatedName = self.nameTextField.text
                    }
//                    if self.updatedUser != nil{
//                    if updatedImgUrl != nil || updatedName != nil{
                    if didUpdate{
                        print("updated user not nil")
                        // make sure that fields actually changed
                        changeRequest?.commitChanges { error in
                            if let error = error {
                                print("error committing")
                                DispatchQueue.main.async {
                                    sender.isEnabled = true
                                    self.hideActivityIndicator(activityView: self.loadingSpinner)
                                    self.showAlert(title: "Error Saving Changes", message: error.localizedDescription)
                                }
                            }
                            else{
                                // update DatabaseManager user
                                DatabaseManager.shared.updateUserProfile(user: self.updatedUser!) { (res) in
                                    switch res{
                                    case .success:
                                        print("successfully updated profile")
                                        DatabaseManager.shared.user = self.updatedUser!
                                        DispatchQueue.main.async {[ weak self ] in
                                            self?.showAlert(title: "Success", message: "Your profile has been updated", completed: { [ weak self] in
                                                self?.navigationController?.popViewController(animated: true)
                                            })
                                        }
                                    case .failure(let err):
                                        print("failed to update profile: \(err.localizedDescription)")
                                        DispatchQueue.main.async {
                                            sender.isEnabled = true
                                            self.showAlert(title: "Failed", message: "Failed to update profile: \(err.localizedDescription). Please try again.")
                                        }
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.hideActivityIndicator(activityView: self.loadingSpinner)
                                }
                            }
                        }
                    }else{
                        print("updated user nil")
                        sender.isEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                    // asynchronously, update profileimg
                }
        }
    }
    
    
    
    
    @objc func uploadProfileTapped(){
        showActivityIndicator(activityView: loadingSpinner, color: UIColor(named: K.Colours.orange)!)
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        imagePickerVC.allowsEditing = true
        present(imagePickerVC, animated: true) {
            self.hideActivityIndicator(activityView: self.loadingSpinner)
        }
    }
    
    fileprivate func onLoginSuccess(){
        guard let tabController = UIApplication.shared.windows[0].rootViewController as? UITabBarController else {return}
        guard let homeNavViewController = tabController.viewControllers![0] as? UINavigationController else {return}
        guard let controller = homeNavViewController.children[0] as? HomeViewController else { return }
        // check if homeview has been built
        DispatchQueue.main.async {
            tabController.selectedIndex = 0
            controller.buildHomeView()
            self.dismiss(animated: true, completion: nil)
            controller.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func fillInUserDetails(){
        guard let user = DatabaseManager.shared.user else { return }
        nameTextField.text = user.name
//        emailTextField.text = user.email
        updateProfileImg(userDetails: user, profilePictureView: profilePictureImageView, loadingSpinner: loadingSpinner)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setup Profile"
        scrollView.frame = view.bounds
        let contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize = contentViewSize
        scrollView.contentInsetAdjustmentBehavior = .automatic
        scrollView.isScrollEnabled = true
        scrollView.addSubview(upperStackView)
        scrollView.addSubview(lowerStackView)
        view.addSubview(scrollView)
        
//        profilePictureImageView.image = UIImage(systemName: "person.circle.fill")
        profilePictureImageView.cropCircle(width: profilePictureSize)
        profilePictureImageView.addCircleGradientBorder()
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
//        profilePictureImageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(profilePictureImageView)
//        profilePictureImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        profilePictureImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//
        displayNameLabel.setupLabel(displayText: "Name", fontSize: 18)
        nameTextField.setupTextField(placeholderText: "", width: view.frame.width * 0.9)
        
        
        profileContainerView.addSubview(profilePictureImageView)
        profileContainerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(profileContainerView)
        profileContainerView.widthAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
        profileContainerView.heightAnchor.constraint(equalToConstant: CGFloat(profilePictureSize)).isActive = true
        
        uploadPhotoButton.setupUnderlineTextButton(btnTitle: "Upload profile picture", fontSize: 18)
        
        setupStackView(upperStackView, alignment: .center)
//        view.addSubview(upperStackView)
        
        setupStackView(lowerStackView, alignment: .leading)
//        view.addSubview(lowerStackView)
        
        upperStackView.addArrangedSubview(profileContainerView)
        upperStackView.addArrangedSubview(uploadPhotoButton)
//        upperStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        upperStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        upperStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        upperStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true
        profileContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadProfileTapped)))
        uploadPhotoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadProfileTapped)))
        
        
        lowerStackView.addArrangedSubview(displayNameLabel)
        lowerStackView.addArrangedSubview(nameTextField)
//        lowerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        lowerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        lowerStackView.topAnchor.constraint(equalTo: upperStackView.bottomAnchor, constant: 10).isActive = true
        
        nextButton.setupNextButton(title: "Save", fontSize: 16, width: 150, height: 50, applyConstraints: false)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        scrollView.addSubview(nextButton)
//        view.addSubview(nextButton)
        nextButton.topAnchor.constraint(equalTo: lowerStackView.bottomAnchor, constant: 20).isActive = true
//        nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    fileprivate func setupStackView(_ stackView: UIStackView, alignment: UIStackView.Alignment) {
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = alignment
        stackView.spacing   = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        self.scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension SetupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            profilePictureImageView.image = image
            self.imgToUpload = image
        }
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
