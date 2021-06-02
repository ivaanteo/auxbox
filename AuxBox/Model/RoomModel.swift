//
//  RoomModel.swift
//  AuxBox
//
//  Created by Ivan Teo on 11/5/21.
//

import Foundation


public struct Room : Codable{
    var roomName:String
    var currentQueue:[String]
    var nowPlaying:SongDetails
    // just note their uid -- is this even necessary?
    var users:[String]
    var toQueue:[String]
  
    enum CodingKeys: String, CodingKey {
        case roomName
        case currentQueue
        case nowPlaying
        case users
        case toQueue
    }

}
