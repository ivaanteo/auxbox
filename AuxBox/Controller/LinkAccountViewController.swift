////
////  LinkAccountViewController.swift
////  AuxBox
////
////  Created by Ivan Teo on 28/4/21.
////
//
//import UIKit
//import SafariServices
//
//class LinkAccountViewController: UIViewController
//{
//
//    private let redirectURI = "INSERT YOUR REDIRECT URL HERE"
//    private let clientID    = "INSERT YOUR CLIENT ID HERE"
//    private let scope       = "user-top-read,"
//                                + "user-read-private,user-read-email,"
//                                + "playlist-modify-public,playlist-modify-private"
//
//    /*
//    Notes:
//      - redirectURI encoded website using https://www.urlencoder.org/
//      - scope, "user-top-read": required scope for reading user's top artists/tracks data "user-top-read"
//      - encodedID = our Basic Auth which is "clientID:clientSecret", base64 encoded using https://www.base64encode.org/
//    */
//
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//        PersistenceManager.saveRefreshToken(refreshToken: "")
//        PersistenceManager.saveAccessToken(accessToken: "")
//    }
//
//    @objc func authorizeUser()
//    {
//        guard let url = URL(string: "\(baseURL.spotify)authorize?client_id=\(clientID)&response_type=code&redirect_uri=\(redirectURI)&scope=\(scope)") else {
//            presentSSAlertOnMainThread(title: "Sorry", message: Message.authorization, isPlaylistAlert: false)
//            return
//        }
//        presentSafariVC(with: url)
//    }
//    
//    private func presentSafariVC(with url: URL)
//    {
//        let safariVC = SFSafariViewController(url: url)
//        safariVC.preferredControlTintColor  = .systemGreen
//        safariVC.preferredBarTintColor      = .black
//        safariVC.delegate                   = self
//        present(safariVC, animated: true)
//    }
//
//    func authorizeFirstTimeUser(with url: String)
//    {
//        // if can't get request token --> auth user
//        // get token from the URL: you might need to change your index here
//        let index = url.index(url.startIndex, offsetBy: 33)
//        let token = url.suffix(from: index)
//
//        NetworkManager.shared.completeAuthorizeRequest(with: String(token)) { results in
//            guard let accessToken = results else {
//                self.dismissLoadingView()
//                self.presentSSAlertOnMainThread(title: "Sorry", message: Message.authorization, isPlaylistAlert: false)
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.dismissLoadingView()
//                let homeVC = HomeViewController()
//                homeVC.OAuthtoken = accessToken
//                self.navigationController?.pushViewController(homeVC, animated: true)
//            }
//        }
//    }
//}
//
//// MARK: - SFSafariViewControllerDelegate
//
//extension LinkAccountViewController: SFSafariViewControllerDelegate
//{
//    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL)
//    {
//        let currentURL = URL.absoluteString
//
//        if currentURL.contains("\(baseURL.colin)?code=")
//        {
//            self.dismiss(animated: true, completion: nil)
////            showLoadingView()
//
//            if PersistenceManager.retrieveRefreshToken() == "" {
//                self.authorizeFirstTimeUser(with: currentURL)
//            } else {
//
//                NetworkManager.shared.getRefreshToken() { results in
//                    guard let accessToken = results else {
//                        self.presentSSAlertOnMainThread(title: "Sorry", message: Message.authorization, isPlaylistAlert: false)
//                        return
//                    }
//
//                    DispatchQueue.main.async {
//                        self.dismissLoadingView()
//                        let homeVC = HomeViewController()
//                        homeVC.OAuthtoken = accessToken
//                        self.navigationController?.pushViewController(homeVC, animated: true)
//                    }
//                }
//            }
//        }
//    }
//}
//
