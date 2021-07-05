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
    var profilePictureURL: String?
    var auxCode: String?
    var joinedRoom: String?
    var credits: Int
    // connected to: -- can connect to own auxcode
}
