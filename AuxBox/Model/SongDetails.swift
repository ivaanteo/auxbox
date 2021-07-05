//
//  SongDetails.swift
//  AuxBox
//
//  Created by Ivan Teo on 29/4/21.
//

import UIKit

struct SongDetails: Codable{
    // this is actually my viewModel
    var songName:String
    var artist:String
    var image:String
    var uri:String
    
    enum CodingKeys: String, CodingKey {
        case songName
        case artist
        case image
        case uri
    }
}
