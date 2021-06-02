//
//  EmailConfirmationViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 26/4/21.
//

import UIKit

class EmailConfirmationViewController : UIViewController{
    let confirmationText = UILabel()
    let confirmationText2 = UILabel()
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
        
//        setupText(confirmationText, message: "Cool, we've just sent you an email!", fontSize: 24)
//        setupText(confirmationText2, message: "Click the link in the email and we'll pass you the aux!", fontSize: 20)
        
        confirmationText.setupLabel(displayText: "Cool, we've just sent you an email!", fontSize: 24)
        confirmationText2.setupLabel(displayText: "Click the link in the email and we'll pass you the aux!", fontSize: 20)
        confirmationText.widthAnchor.constraint(equalToConstant: view.frame.width*0.8).isActive=true
        confirmationText2.widthAnchor.constraint(equalToConstant: view.frame.width*0.8).isActive=true
        
//        confirmationText.textContainer.lineBreakMode = .byWordWrapping
//        confirmationText.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(confirmationText)
//        confirmationText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
//        confirmationText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
//        confirmationText.centerYAnchor = view.centerYAnchor
//        confirmationText.centerXAnchor = view.centerXAnchor
        
        let stackView = UIStackView()
        setupStackView(stackView, confirmationText, confirmationText2)
        self.view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
    }
    fileprivate func setupStackView(_ stackView: UIStackView, _ loginText: UILabel, _ text2: UILabel) {
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.leading

        stackView.addArrangedSubview(loginText)
        stackView.addArrangedSubview(text2)
        stackView.setCustomSpacing(4, after: loginText)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
//    fileprivate func setupText(_ text: UITextView, message: String, fontSize: CGFloat) {
//        text.center = self.view.center
//        text.textColor = UIColor.white
//        text.font = UIFont(name: "Futura", size: fontSize)
//        text.backgroundColor = .none
//        text.text = message
//        text.isScrollEnabled = false
//        text.textContainer.lineBreakMode = .byWordWrapping
//        text.widthAnchor.constraint(equalToConstant: view.frame.width-40).isActive = true
//    }
}
