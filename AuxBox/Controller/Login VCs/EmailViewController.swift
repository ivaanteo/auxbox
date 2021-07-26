//
//  EmailViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 25/4/21.
//

import UIKit
import Firebase

class EmailViewController: UIViewController{
    fileprivate var emailString: String?
    let loginLabel = UILabel()
    let emailInput = PaddedTextField()
    let passwordLabel = UILabel()
    let passwordTextField = PaddedTextField()
    let errLabel = UILabel()
    
    let nextButton = NextButton()
    
    
    let passwordToggleButton = UIButton(type: .custom)
    
//    let passwordVerifier = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func resetPassword(){
        let resetPasswordVC = ResetPasswordViewController()
        resetPasswordVC.title = "Reset Password"
        navigationController?.pushViewController(resetPasswordVC, animated: true)
    }
    
    @objc func nextTapped(sender: UIButton!) {
        guard emailInput.text != "" else {
            errLabel.text = "Oops, seems like you forgot to enter an email!"
            shakeView(view: emailInput)
            return }
        
        guard passwordTextField.text != "" else {
            errLabel.text = "Oops, seems like you forgot to enter a password"
            shakeView(view: passwordTextField)
            return }
        
        guard isValidEmail(email: emailInput.text!) else {
            errLabel.text = "That's not a valid email, please check again!"
            shakeView(view: emailInput)
            return
        }
        
//        guard passwordVerifier.evaluate(with: passwordTextField.text) else {
//            errLabel.text = "Your password needs to be 8 characters long, with 1 capital letter and 1 number! Please try again."
//            shakeView(view: passwordTextField)
//            return
//        }
        
        guard let email = emailInput.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard error == nil else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        DispatchQueue.main.async {
                            self.errLabel.text = "That's not a valid email, please check again!"
                            self.shakeView(view: self.emailInput)
                            print("invalid email")
                        }
                    case .emailAlreadyInUse:
                        Auth.auth().fetchSignInMethods(forEmail: email) { (res, err) in
                            guard err == nil else { return }
                            guard let listOfProviders = res else { return }
                            // password, facebook.com
                            if listOfProviders.contains("password"){
                                // sign in by email and password
                                Auth.auth().signIn(withEmail: email, password: password) { (loginAuthResult, error) in
                                    guard error == nil else {
                                        if let errCode = AuthErrorCode(rawValue: error!._code) {
                                            switch errCode {
                                            case .wrongPassword:
                                                DispatchQueue.main.async {
                                                    self.errLabel.text = "Oops, you've entered an invalid password."
                                                    self.shakeView(view: self.passwordTextField)
                                                }
                                            default:
                                                DispatchQueue.main.async {
                                                    self.showAlert(title: "Oops", message: "Error signing in: \(String(describing: error?.localizedDescription))")
                                                }
                                            }
                                        }
                                        return
                                    }
                                    guard let currUser = loginAuthResult?.user else { return }
                                    if currUser.isEmailVerified{
                                        PersistenceManager.setEmailLoginVerified(loggedIn: true)
                                        self.onLoginSuccess()
                                    }else{
                                        guard let unwrappedAuthResult = loginAuthResult else { return }
                                        self.showVerificationVC(user: unwrappedAuthResult.user)
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.showAlert(title: "Oops", message: "You already have an account. Please sign in by one of the following: \(listOfProviders.joined(separator: ","))")
                                }
                            }
                            
                        }
                    default:
                        print("Create User Error: \(error!)")
                        self.showAlert(title: "Oops", message: "Error creating account: \(String(describing: error?.localizedDescription))")
                    }
                }
                return
            }
            
            // success
            guard let unwrappedAuthResult = authResult else { return }
            self.showVerificationVC(user: unwrappedAuthResult.user)
        }
    }
    
    fileprivate func showVerificationVC(user: User){
        let confirmationVC = EmailConfirmationViewController()
        DispatchQueue.main.async {
            confirmationVC.userToVerify = user
            self.navigationController?.pushViewController(confirmationVC, animated: true)
        }
    }
    
    @objc func togglePasswordVisibility(sender: UIButton!){
        DispatchQueue.main.async {
            self.passwordTextField.isSecureTextEntry.toggle()
            if self.passwordTextField.isSecureTextEntry{
                self.passwordToggleButton.setImage(UIImage(systemName: "eyes"), for: .normal)
            }else{
                self.passwordToggleButton.setImage(UIImage(systemName: "eyes.inverse"), for: .normal)
            }
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
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        title = "Continue with Email"
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset Password", style: .plain, target: self, action: #selector(resetPassword))
        
        loginLabel.setupLabel(displayText: "All we need is your email,", fontSize: 18)
        
        //      email text field
        emailInput.setupTextField(placeholderText: "eg. example@gmail.com", width: view.frame.width*0.8)
        emailInput.textContentType = .emailAddress
        emailInput.keyboardType = .emailAddress
        emailInput.autocapitalizationType = .none
        emailInput.becomeFirstResponder()
        emailInput.delegate = self
        
        passwordLabel.setupLabel(displayText: "and password!", fontSize: 18)
        
        passwordTextField.setupTextField(placeholderText: "shhh.. don't tell anyone", width: view.frame.width*0.8)
//        passwordTextField.setupTextField(placeholderText: "8 characters: 1 uppercase and 1 number", width: view.frame.width*0.8)
        passwordTextField.textContentType = .newPassword
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        
        passwordToggleButton.setImage(UIImage(systemName: "eyes"), for: .normal)
        passwordToggleButton.imageView?.tintColor = UIColor(named: K.Colours.orange)
        passwordToggleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -25, bottom: 0, right: 0)
        //        passwordToggleButton.frame = CGRect(x: CGFloat(passwordTextField.frame.size.width - 30), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordTextField.rightView = passwordToggleButton
        passwordTextField.rightViewMode = .always
        
        // next button
        nextButton.setupNextButton(title: "Next", fontSize: 14, width: 120, height: 40)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
//        errLabel.setupLabel(displayText: "", fontSize: 14, overrideText: false)
        errLabel.setupLabel(displayText: "We'll check if you're a new user or a returning one.", fontSize: 14)
        errLabel.translatesAutoresizingMaskIntoConstraints = false
        errLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9).isActive = true
        
        //      StackView stuff
        let stackView = UIStackView()
        setupStackView(stackView)
        self.view.addSubview(stackView)
        //        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    fileprivate func setupStackView(_ stackView: UIStackView) {
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.leading
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.addArrangedSubview(loginLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(passwordLabel)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(nextButton)
        stackView.addArrangedSubview(errLabel)
        stackView.setCustomSpacing(20, after: emailInput)
        stackView.setCustomSpacing(20, after: passwordTextField)
        //        stackView.setCustomSpacing(24, after: emailInput)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func isValidEmail(email: String) -> Bool {
        guard !email.lowercased().hasPrefix("mailto:") else {
            return false
        }
        guard let emailDetector
                = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        let matches
            = emailDetector.matches(in: email,
                                    options: NSRegularExpression.MatchingOptions.anchored,
                                    range: NSRange(location: 0, length: email.count))
        guard matches.count == 1 else {
            return false
        }
        return matches[0].url?.scheme == "mailto"
    }
}

extension EmailViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailInput{
            textField.resignFirstResponder()
        }
    }
}
