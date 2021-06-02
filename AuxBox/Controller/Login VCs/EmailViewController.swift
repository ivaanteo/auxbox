//
//  EmailViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 25/4/21.
//

import UIKit
import Firebase

class EmailViewController: UIViewController, UITextFieldDelegate{
    fileprivate var emailString: String?
    
    @objc func nextTapped(sender: UIButton!) {
        let confirmationVC = EmailConfirmationViewController()
        self.navigationController?.pushViewController(confirmationVC, animated: true)
        confirmationVC.title = "Email Confirmation"
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
//        navigationItem.largeTitleDisplayMode = .never

        
        let loginText = UILabel()
//        setupText(loginText, message: "All we need is your email!")
        loginText.setupLabel(displayText: "All we need is your email!", fontSize: 24)
        
//      email text field
        let emailInput = PaddedTextField()
//        setupTextField(emailInput)
        emailInput.setupTextField(placeholderText: "eg. example@gmail.com", width: view.frame.width*0.8)
        emailInput.becomeFirstResponder()
        emailInput.delegate = self
        
        // next button
        let nextButton = NextButton()
        nextButton.setupNextButton(title: "Next", fontSize: 16, width: 150, height: 50)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        
//      StackView stuff
        let stackView = UIStackView()
        setupStackView(stackView, loginText, emailInput, nextButton)
        self.view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    }
//    fileprivate func setupTextField(_ emailInput: PaddedTextField) {
//        emailInput.borderStyle = UITextField.BorderStyle.roundedRect
//        emailInput.widthAnchor.constraint(equalToConstant: view.frame.width-32).isActive = true
//        emailInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        emailInput.layer.cornerRadius = 20
//        emailInput.clipsToBounds = true
//        // Set UITextField background colour
//        emailInput.backgroundColor = UIColor.white
//        // Set UITextField text color
//        emailInput.textColor = UIColor(named: K.Colours.textColour)
//    }
    
//    fileprivate func setupText(_ loginText: UITextView, message: String) {
//        loginText.center = self.view.center
//        loginText.textColor = UIColor.white
//        loginText.font = UIFont(name: "Futura", size: 24)
//        loginText.backgroundColor = .none
//        loginText.text = message
//        loginText.isScrollEnabled = false
//    }
    
    fileprivate func setupStackView(_ stackView: UIStackView, _ loginText: UILabel, _ emailInput: PaddedTextField, _ nextButton: NextButton) {
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.leading
//        stackView.distribution = .equalSpacing
//        stackView.spacing = 24
        stackView.addArrangedSubview(loginText)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(nextButton)
        stackView.setCustomSpacing(16, after: loginText)
        stackView.setCustomSpacing(24, after: emailInput)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
}

extension EmailViewController{
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.emailString = textField.text
    }
}
