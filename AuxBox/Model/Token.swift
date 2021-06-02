//
//  Token.swift
//  AuxBox
//
//  Created by Ivan Teo on 29/4/21.
//

import Foundation
struct Token:Decodable{
    let accessToken:String?
    let tokenType:String?
    let refreshToken:String?
    let expiresIn:Int?
    let scope:String?
    
    let error:String?
    let errorDescription:String?
}

struct ClientToken:Decodable{
    let accessToken:String?
    let tokenType:String?
    let expiresIn:Int?
    
    let error:String?
    let errorDescription:String?
}
