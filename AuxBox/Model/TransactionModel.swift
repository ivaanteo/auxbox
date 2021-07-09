//
//  TransactionModel.swift
//  AuxBox
//
//  Created by Ivan Teo on 8/7/21.
//

import UIKit

struct TransactionModel: Codable{
    var songURI: String
    var timestamp: Double
    var sender: String
    var recipient: String
    enum CodingKeys: String, CodingKey {
        case songURI
        case timestamp
        case sender
        case recipient
    }
}

