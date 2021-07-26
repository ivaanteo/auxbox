//
//  SpotifyAPIHelpers.swift
//  AuxBox
//
//  Created by Ivan Teo on 28/4/21.
//

import Foundation

struct SpotifyAPI{
    static let accountURL = "https://accounts.spotify.com/"
    static let baseURL = "https://api.spotify.com/v1/"
    static let clientID = "674cd699c32e453ca39240861f9b2a3f"
    static let redirectURI = "https%3A%2F%2Fwww.google.com%2F"
    static let redirectURL = "https://www.google.com/"
}

struct Key{
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
    static let clientAccessToken = "clientAccessToken"
    static let spotifyId = "spotifyId"
    static let emailVerificationTime = "emailVerificationTime"
    static let emailLoginVerified = "emailLoginVerified"
}

struct HeaderField{
    static let authorization = "Authorization"
    static let contentType = "Content-Type"
    static let grantType = "grant_type"
    static let refreshToken = "refresh_token"
    static let accessToken = "access_token"
    static let code = "code"
    static let redirectUri = "redirect_uri"
    static let query = "q"
    static let type = "type"
    static let scope = "user-top-read%20user-modify-playback-state%20user-read-currently-playing%20user-read-private%20user-read-email"
}
