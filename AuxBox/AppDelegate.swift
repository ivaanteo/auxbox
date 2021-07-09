//
//  AppDelegate.swift
//  AuxBox
//
//  Created by Ivan Teo on 16/4/21.
//

import UIKit
import FBSDKCoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
//        ApplicationDelegate.shared.application(
//            application,
//            didFinishLaunchingWithOptions: launchOptions
//        )
        ApplicationDelegate.initializeSDK(nil)
        Settings.isAutoLogAppEventsEnabled = true
        Settings.setAdvertiserTrackingEnabled(true)
        Settings.isAdvertiserIDCollectionEnabled = true
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Futura", size: 17)!]
        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont(name: "Futura", size: 26)!]
        UINavigationBar.appearance().barTintColor = UIColor(named: "bgColour")
        UINavigationBar.appearance().tintColor = UIColor(named: "auxOrange")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 1)]
        
            // check if user is logged
        
        
//        switch Service.authState {
//            case .signedIn:
//                print("Signed in")
//    //            let vc = sb.instantiateViewController(withIdentifier: loginViewControllerId)
//            case .signedOut:
//                print("Signed out")
//    //            gotToSignInViewController()
//        }
        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // background task
        if DatabaseManager.shared.user?.joinedRoom == DatabaseManager.shared.user?.auxCode{
            // delete room if you're the host
            DatabaseManager.shared.deleteActiveRoom()
        }
    }

}
    
