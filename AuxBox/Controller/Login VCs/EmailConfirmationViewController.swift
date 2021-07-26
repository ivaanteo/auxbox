//
//  EmailConfirmationViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 26/4/21.
//

import UIKit
import FirebaseAuth

class EmailConfirmationViewController : UIViewController{
    let confirmationText = UILabel()
    let confirmationText2 = UILabel()
    let resendEmailButton = UIButton()
    let emailVerifiedButton = NextButton()
    var userToVerify:User?{
        didSet{
            if PersistenceManager.canResendEmailVerification(){
                sendEmail()
                print("sent")
            }else{
                print("did not send")
            }
        }
    }
    
    var myTimer = Timer()
    var secondsToCount = K.timeBetweenEmails
    
    @objc func updateTimer() {
        if secondsToCount > 0{
            secondsToCount -= 1
            resendEmailButton.setTitle("Send again in \(secondsToCount)s", for: .normal)
        }else{
            myTimer.invalidate()
            resendEmailButton.setTitle("Resend Confirmation Email", for: .normal)
            self.secondsToCount = K.timeBetweenEmails
        }
        
    }
    
    @objc func resendEmailTapped(sender: UIButton!){
        if PersistenceManager.canResendEmailVerification(){
            sendEmail()
            
            // start timer
            myTimer.invalidate()
            myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }else{
            shakeView(view: sender, highlightBorder: false)
        }
    }
    
    @objc func willEnterForeground() {
        // check that button tapped
        Auth.auth().currentUser?.reload(completion: { (err) in
            guard err == nil else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Could not refresh user: \(err!.localizedDescription)")
                }
                return }
            guard let user = Auth.auth().currentUser else { return }
            if user.isEmailVerified{
                // set localstorage
                PersistenceManager.setEmailLoginVerified(loggedIn: true)
                // setup name and photo
                let setupProfileVC = SetupProfileViewController()
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(setupProfileVC, animated: true)
                }
            }
            else{
                self.shakeView(view: self.emailVerifiedButton, highlightBorder: true)
            }
        })
    }
    
    
    fileprivate func sendEmail(){
        self.userToVerify?.sendEmailVerification(completion: { (err) in
            guard err == nil else {
                DispatchQueue.main.async {
                    self.shakeView(view: self.resendEmailButton, highlightBorder: false)
                }
                return }
            PersistenceManager.setEmailVerificationSent()
        })
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
        title = "Email Confirmation"
        confirmationText.setupLabel(displayText: "We've sent an email to \(Auth.auth().currentUser?.email ?? "you").", fontSize: 18)
        confirmationText2.setupLabel(displayText: "Click the link in the email and we'll pass you the aux!", fontSize: 18)
        confirmationText.widthAnchor.constraint(equalToConstant: view.frame.width*0.8).isActive=true
        confirmationText2.widthAnchor.constraint(equalToConstant: view.frame.width*0.8).isActive=true
        resendEmailButton.setTitle("Resend Confirmation Email", for: .normal)
        resendEmailButton.addTarget(self, action: #selector(resendEmailTapped), for: .touchUpInside)
        emailVerifiedButton.setupNextButton(title: "I've confirmed my email", fontSize: 16, width: 200, height: 50)
        emailVerifiedButton.addTarget(self, action: #selector(willEnterForeground), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        
        
        let stackView = UIStackView()
        setupStackView(stackView, confirmationText, confirmationText2)
        self.view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    }
    
    
    fileprivate func setupStackView(_ stackView: UIStackView, _ loginText: UILabel, _ text2: UILabel) {
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.alignment = UIStackView.Alignment.leading
        
        stackView.addArrangedSubview(loginText)
        stackView.addArrangedSubview(text2)
        stackView.addArrangedSubview(emailVerifiedButton)
        stackView.addArrangedSubview(resendEmailButton)
        stackView.setCustomSpacing(4, after: loginText)
        stackView.setCustomSpacing(20, after: confirmationText2)
        stackView.setCustomSpacing(20, after: emailVerifiedButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
}
