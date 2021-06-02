//
//  SceneDelegate.swift
//  AuxBox
//
//  Created by Ivan Teo on 16/4/21.
//

import UIKit
import FBSDKCoreKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate{
    
    static private let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string:"AuxBox://")!
    private let clientIdentifier = "674cd699c32e453ca39240861f9b2a3f"
    
    let navController = UINavigationController(rootViewController: HomeViewController())
    var firstLoad = true
    var homeVC: HomeViewController{
        get{
            navController.children[0] as! HomeViewController
//            navController.topViewController as! HomeViewController
        }
    }
    
    var locationVC: LocationViewController{
        get{
//            if homeVC.navLocVC.topViewController is LocationViewController{
//                return homeVC.navLocVC.topViewController as! LocationViewController
//            }
//
            
//            if let locationVC = homeVC.navLocVC.topViewController as! LocationViewController{
//                return locationVC
//            }
            return homeVC.navLocVC.children[0] as! LocationViewController
        }
    }
    
    var window: UIWindow?
    
    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
        }
    }
    
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {return}
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
        
        let parameters = appRemote.authorizationParameters(from: url);

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            homeVC.presentAlert(title: "Oops, something went wrong!", message: errorDescription)
        }
        
        
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
//        connect();
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
//        rootViewController.appRemoteDisconnect()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
//        rootViewController.appRemoteConnecting()
        // if session is live, connect app remote
        
        // this runs for non-first time login
        print("database constants: \(DatabaseManager.user?.joinedRoom), \(DatabaseManager.user?.auxCode)")
        guard DatabaseManager.user?.joinedRoom != nil else { return }
        // nil = nil
        if DatabaseManager.user?.auxCode == DatabaseManager.user?.joinedRoom{
            appRemote.connect()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        if appRemote.isConnected{
            appRemote.disconnect()
        }
    }
    
    func connect() {
//        rootViewController.appRemoteConnecting()
        appRemote.connect()
    }
    
    // MARK: AppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        homeVC.subscribeToPlayerState()
        
        if homeVC.navLocVC.topViewController is LocationViewController{
            locationVC.finishCreatingRoom()
            print("executes LocationVC.finishCreatingRoom")
        }
        
        
//        if homeVC.navLocVC.topViewController is LocationViewController && !firstLoad{
//            locationVC.finishCreatingRoom()
//            print("executes LocationVC.finishCreatingRoom")
//        }else{
//            firstLoad=false
//        }
        
        
        
        
//        rootViewController.appRemoteConnected()
//        locationViewController.appRemoteConnected()
        print("app remote did establish Connection")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("didFailConnectionAttemptWithError")
//        rootViewController.appRemoteDisconnect()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        homeVC.unsubscribeFromPlayerState()
        print("didDisconnectWithError")
//        rootViewController.appRemoteDisconnect()
    }


}

