////
////  PersistenceActionType.swift
////  SpotifyStats
////
////  Created by Colin Murphy on 7/10/20.
////  Copyright © 2020 Colin Murphy. All rights reserved.
////
//
import Foundation
import Foundation

enum PersistenceActionType {
    // what this shit for??
    case add, remove
}

enum PersistenceManager
{
    static private let defaults = UserDefaults.standard
    
    // Retrieves access token from userDefaults
    static func retrieveAccessToken() -> String
    {
        guard let data = defaults.object(forKey: Key.accessToken) as? Data else { return "" }
        
        do {
            let decoder = JSONDecoder()
            let token = try decoder.decode(String.self, from: data)
//            print("retrieve access token: \(token)")
            return token
        } catch {
            return ""
        }
    }
    
    static func retrieveClientAccessToken() -> String
    {
        guard let data = defaults.object(forKey: Key.clientAccessToken) as? Data else { return "" }
        
        do {
            let decoder = JSONDecoder()
            let token = try decoder.decode(String.self, from: data)
            return token
        } catch {
            return ""
        }
    }


    // Retrieves refresh token from userDefaults
    static func retrieveRefreshToken() -> String
    {
        guard let data = defaults.object(forKey: Key.refreshToken) as? Data else { return "" }
        
        do {
            let decoder = JSONDecoder()
            let token = try decoder.decode(String.self, from: data)
//            print("retrieve refresh token: \(token)")
            return token
        } catch {
            return ""
        }
    }
    
    // Saves access token to userDefaults
    static func saveAccessToken(accessToken: String) -> Void?
    {
        do {
            let encoder = JSONEncoder()
            let encodedAccessToken = try encoder.encode(accessToken)
            defaults.set(encodedAccessToken, forKey: Key.accessToken)
//            print(defaults.data(forKey: Key.accessToken))
            return nil
        } catch {
            return nil
        }
    }
    
    // non profile related
    static func saveClientAccessToken(clientAccessToken: String) -> Void?
    {
        do {
            let encoder = JSONEncoder()
            let encodedAccessToken = try encoder.encode(clientAccessToken)
            defaults.set(encodedAccessToken, forKey: Key.clientAccessToken)
            return nil
        } catch {
            return nil
        }
    }
    
    // Saves refresh token to userDefaults
    static func saveRefreshToken(refreshToken: String) -> Void?
    {
        do {
            let encoder = JSONEncoder()
            let encodedRefreshToken = try encoder.encode(refreshToken)
            defaults.set(encodedRefreshToken, forKey: Key.refreshToken)
//            print(defaults.data(forKey: Key.refreshToken))
            return nil
        } catch {
            return nil
        }
    }
}
