////
////  SpotifySDKStuff.swift
////  AuxBox
////
////  Created by Ivan Teo on 10/5/21.
////
//
//import Foundation
////MARK: Spotify Variables
//private let SpotifyClientID = "674cd699c32e453ca39240861f9b2a3f"
//private let SpotifyRedirectURI = URL(string: "https://www.google.com/")!
//private let encodedID  = "Njc0Y2Q2OTljMzJlNDUzY2EzOTI0MDg2MWY5YjJhM2Y6NjQ5NmRjZGFhNGJhNDQxYWIwMWU1NWMwZTc1OGNmNzE="
//
//let stringScopes = ["app-remote-control", "playlist-read-private"]
//
//    lazy var configuration: SPTConfiguration = {
//        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
//        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
//        // otherwise another app switch will be required
//        configuration.playURI = ""
//
//        // Set these url's to your backend which contains the secret to exchange for an access token
//        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
//        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
//        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
//        
//        return configuration
//    }()
//
//    lazy var sessionManager: SPTSessionManager = {
//        let manager = SPTSessionManager(configuration: configuration, delegate: self)
//        return manager
//    }()
//
//    lazy var appRemote: SPTAppRemote = {
//        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
//        appRemote.delegate = self
//        return appRemote
//    }()
//
//    private var lastPlayerState: SPTAppRemotePlayerState?
//
//var codeVerifier: String = ""
//    var responseTypeCode: String? {
//        didSet {
//            fetchSpotifyToken { (dictionary, error) in
//                if let error = error {
//                    print("Fetching token request error \(error)")
//                    return
//                }
//                let accessToken = dictionary!["access_token"] as! String
//                DispatchQueue.main.async {
//                    self.appRemote.connectionParameters.accessToken = accessToken
//                    self.appRemote.connect()
//                }
//            }
//        }
//    }
//var accessToken = UserDefaults.standard.string(forKey: K.SpotifyKeys.accessTokenKey) {
//        didSet {
//            let defaults = UserDefaults.standard
//            defaults.set(accessToken, forKey: K.SpotifyKeys.accessTokenKey)
//        }
//    }
//
//func update(playerState: SPTAppRemotePlayerState) {
//        if lastPlayerState?.track.uri != playerState.track.uri {
//            fetchArtwork(for: playerState.track)
//        }
//        lastPlayerState = playerState
//        print(playerState.track.name)
//    }
//
//    func updateViewBasedOnConnected() {
//        if appRemote.isConnected == true {
//            print("is connected")
//        } else { //show login
//            print("not connected")
//        }
//    }
//
//    func fetchArtwork(for track: SPTAppRemoteTrack) {
//        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
//            if let error = error {
//                print("Error fetching track image: " + error.localizedDescription)
//            } else if let image = image as? UIImage {
//                // set image to artwork
//                print("setted image to artwork")
//            }
//        })
//    }
//
//    func fetchPlayerState() {
//        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
//            if let error = error {
//                print("Error getting player state:" + error.localizedDescription)
//            } else if let playerState = playerState as? SPTAppRemotePlayerState {
//                self?.update(playerState: playerState)
//            }
//        })
//    }
//let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
//if #available(iOS 11, *) {
//  // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
//    print("initiate")
//    sessionManager.initiateSession(with: scope, options: .clientOnly)
//} else {
//  // Use this on iOS versions < 11 to use SFSafariViewController
//    sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
//}

//
//
//extension HomeViewController: SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate{
//    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        // update view
//            appRemote.playerAPI?.delegate = self
//            appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
//                if let error = error {
//                    print("Error subscribing to player state:" + error.localizedDescription)
//                }
//            })
//            print("did establish connection")
//        }
//
//        func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//            // update view
//            lastPlayerState = nil
//        }
//
//        func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//            // update view
//            lastPlayerState = nil
//        }
//    
//    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        debugPrint("Spotify Track name: %@", playerState.track.name)
//        update(playerState: playerState)
//    }
//}
//
//
//extension HomeViewController: SPTSessionManagerDelegate {
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        print("failed af man")
//        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
//            print("AUTHENTICATE with WEBAPI")
//        } else {
//           print("problem")
//        }
//    }
//
//    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//        print("did renew")
//    }
//
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        appRemote.connectionParameters.accessToken = session.accessToken
//        appRemote.connect()
//        print("did initiate")
//    }
//}
//
//func fetchSpotifyToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
//        let url = URL(string: "https://accounts.spotify.com/api/token")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let spotifyAuthKey = "Basic \(encodedID)"
//        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
//                                       "Content-Type": "application/x-www-form-urlencoded"]
//        do {
//            var requestBodyComponents = URLComponents()
//            let scopeAsString = stringScopes.joined(separator: " ") //put array to string separated by whitespace
//            requestBodyComponents.queryItems = [
//                URLQueryItem(name: "client_id", value: SpotifyClientID),
//                URLQueryItem(name: "grant_type", value: "authorization_code"),
//                URLQueryItem(name: "code", value: responseTypeCode!),
//                URLQueryItem(name: "redirect_uri", value: SpotifyRedirectURI.absoluteString),
//                URLQueryItem(name: "code_verifier", value: codeVerifier),
//                URLQueryItem(name: "scope", value: scopeAsString),
//            ]
//            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let data = data,                            // is there data
//                    let response = response as? HTTPURLResponse,  // is there HTTP response
//                    (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
//                    error == nil else {                           // was there no error, otherwise ...
//                        print("Error fetching token \(error?.localizedDescription ?? "")")
//                        return completion(nil, error)
//                }
//                let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
//                print("Access Token Dictionary=", responseObject ?? "")
//                completion(responseObject, nil)
//            }
//            task.resume()
//        } catch {
//            print("Error JSON serialization \(error.localizedDescription)")
//        }
//    }
//let parameters = rootViewController.appRemote.authorizationParameters(from: url)
//       if let code = parameters?["code"] {
//           rootViewController.responseTypeCode = code
//       } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
//           rootViewController.accessToken = access_token
//       } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
//           print("No access token error =", error_description)
//       }

//Scene delegate
//if let accessToken = rootViewController.appRemote.connectionParameters.accessToken {
//            rootViewController.appRemote.connectionParameters.accessToken = accessToken
//            rootViewController.appRemote.connect()
//        } else if let accessToken = rootViewController.accessToken {
//            rootViewController.appRemote.connectionParameters.accessToken = accessToken
//            rootViewController.appRemote.connect()
//        }
//
//if (rootViewController.appRemote.isConnected) {
//    rootViewController.appRemote.disconnect()
//    }
