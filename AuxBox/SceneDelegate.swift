//
//  SceneDelegate.swift
//  AuxBox
//
//  Created by Ivan Teo on 16/4/21.
//

import UIKit
import FBSDKCoreKit
import Firebase
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, CLLocationManagerDelegate{
    
    static private let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string:"AuxBox://")!
    private let clientIdentifier = "674cd699c32e453ca39240861f9b2a3f"
    
    
    let tabController = TabBarController()
    
//    let navController = UINavigationController(rootViewController: HomeViewController())
//    var firstLoad = true
    var homeVC: HomeViewController{
        get{
//            navController.children[0] as! HomeViewController
            let homeNavViewController = tabController.viewControllers![0] as! UINavigationController
            let homeViewController = homeNavViewController.children[0] as! HomeViewController
//            let selectedNavVC = tabController.selectedViewController as! UINavigationController
//            if selectedNavVC.topViewController is HomeViewController {
//            let homeViewController = selectedNavVC.topViewController as! HomeViewController
            return homeViewController
        }
    }
    
    // WANT TO REMOVE THIS
//    var locationVC: LocationViewController{
//        get{
////            if homeVC.navLocVC.topViewController is LocationViewController{
////                return homeVC.navLocVC.topViewController as! LocationViewController
////            }
////
//
////            if let locationVC = homeVC.navLocVC.topViewController as! LocationViewController{
////                return locationVC
////            }
//
//
//
//            return homeVC.navLocVC.children[0] as! LocationViewController
//        }
//    }
    
    var window: UIWindow?
    
    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    lazy var locationManager: CLLocationManager = {
        
        // singleton
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        return locationManager
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
//        window?.rootViewController = navController
        window?.rootViewController = tabController
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
        guard DatabaseManager.shared.user?.joinedRoom != nil else { return }
        // nil = nil
        if DatabaseManager.shared.user?.auxCode == DatabaseManager.shared.user?.joinedRoom{
            appRemote.connect()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
//        if appRemote.isConnected{
//            appRemote.disconnect()
//        }
    }
    
    func connect() {
//        rootViewController.appRemoteConnecting()
        appRemote.connect()
    }
    
    // MARK: AppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        homeVC.subscribeToPlayerState()
        
        // here we connect
        // get location, save to firebase
        
        guard let navLocVC = tabController.presentedViewController as? UINavigationController else {
            // likely this will pass because all presented view controllers are navigation controllers
            print("not nav vc")
            return }
        guard let locVC = navLocVC.topViewController as? LocationViewController else {
            // occurs when user has an active room on login
            print("not location vc")
            return }
        locVC.finishCreatingRoom()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let navLocVC = tabController.presentedViewController as? UINavigationController else {
            // likely this will pass because all presented view controllers are navigation controllers
            print("not nav vc")
            return }
        guard let locVC = navLocVC.topViewController as? LocationViewController else {
            print("not location vc")
            // means that location update comes from hosting room
            DatabaseManager.shared.updateLocation(location: locations[0])
            return }
        // if its indeed location vc, go ahead and retrieve what you need
        locVC.retrievedLocation(location: locations[0])
        
        
        
//        if homeVC.navLocVC.topViewController is LocationViewController{
//            locationVC.retrievedLocation(location: locations[0])
//        }else{
//            print("updating location: ", locations[0])
////            print(locations[0].coordinate)
//            // update database every 2 mins? ye prolly or every song change... ye thats about right
//            // wait if dudes not playing any song then....... idk
//            DatabaseManager.shared.updateLocation(location: locations[0])
//        }
        
//        print("selected vc: \(String(describing: type(of: tabController.selectedViewController.self)) )")
//        print("presented vc: \(String(describing: type(of: tabController.presentedViewController.self)) )")
//        print("selected vc: \(NSStringFromClass(tabController.selectedViewController!.classForCoder))")
//        print("presented vc: \(NSStringFromClass(tabController.presentedViewController!.classForCoder))")
        
//        print("selected vc: \(NSStringFromClass(tabController.selectedViewController))")
        
//        let selectedNavVC = tabController.presentedViewController as! UINavigationController
//        print("presentedViewController: \(NSStringFromClass(selectedNavVC.topViewController!.classForCoder))")
//        let locVC = selectedNavVC.topViewController as! LocationViewController
//        locVC.retrievedLocation(location: locations[0])
        
//        let selectedNavVC = tabController.selectedViewController as! UINavigationController
//        let homeViewController = selectedNavVC.topViewController as! HomeViewController
//        if homeVC.navLocVC.topViewController is LocationViewController{
//            let locVC = homeViewController.navLocVC.topViewController as! LocationViewController
//            locVC.retrievedLocation(location: locations[0])
//        }else{
//            DatabaseManager.shared.updateLocation(location: locations[0])
//        }
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("did fail with error")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("did change authorisation")
//        manager.requestLocation()
//        locationManager.requestLocation()
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("paused")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("location updates resumed")
    }

}

