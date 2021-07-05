//
//  Constants.swift
//  AuxBox
//
//  Created by Ivan Teo on 29/4/21.
//

import Foundation

struct K{
    struct Colours {
        static let bgColour = "bgColour"
        static let orange = "auxOrange"
        static let purple = "auxPurple"
        static let textColour = "textColour"
        static let offWhite = "offWhite"
    }
    
    struct FStore {
        static let usersCollection = "users"
        static let roomsCollection = "rooms"
        static let displayName = "displayName"
        static let email     = "email"
        static let profilePic    = "profilePicURL"
        
        static let auxCodeField = "auxCode"
    }
    struct SpotifyKeys{
        static let accessTokenKey = "access-token-key"
        static let auxCodeKey = "auxCodeKey"
    }
    
    struct Texts{
        static let queuedSongText = "Great choice! Your song will played soon."
    }
    
    
}
