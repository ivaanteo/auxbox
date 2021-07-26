//
//  ResetPasswordViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 15/7/21.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController{
    fileprivate var emailString: String?
    let loginLabel = UILabel()
    let emailInput = PaddedTextField()
    let errLabel = UILabel()
    let nextButton = NextButton()
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func nextTapped(sender: UIButton!) {
        guard let email = emailInput.text else { return }
        guard email != "" else {
            errLabel.text = "Oops, seems like you forgot to enter an email!"
            shakeView(view: emailInput)
            return }
        
        guard isValidEmail(email: email) else {
            errLabel.text = "That's not a valid email, please check again!"
            shakeView(view: emailInput)
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if let err = err {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Error sending email: \(err.localizedDescription)")
                    self.shakeView(view: self.emailInput)
                }
                return
            }
            // success
            DispatchQueue.main.async {
                self.showAlert(title: "Reset email sent", message: "Follow the instructions to reset your password.")
            }
        }
    }
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
        
        loginLabel.setupLabel(displayText: "All we need is your email,", fontSize: 18)
        
        //      email text field
        emailInput.setupTextField(placeholderText: "eg. example@gmail.com", width: view.frame.width*0.8)
        emailInput.textContentType = .emailAddress
        emailInput.keyboardType = .emailAddress
        emailInput.autocapitalizationType = .none
        emailInput.becomeFirstResponder()
        emailInput.delegate = self
        
        
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
        stackView.addArrangedSubview(nextButton)
        stackView.addArrangedSubview(errLabel)
        stackView.setCustomSpacing(20, after: emailInput)
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

extension ResetPasswordViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}
