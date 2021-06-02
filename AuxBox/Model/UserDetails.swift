//
//  UserDetails.swift
//  AuxBox
//
//  Created by Ivan Teo on 26/4/21.
//

import Foundation

struct UserDetails : Codable {
    var name: String?
    var email: String?
    var profilePictureURL: URL?
    var auxCode: String?
    var joinedRoom: String?
    // connected to: -- can connect to own auxcode
}
