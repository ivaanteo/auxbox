//
//  RoomModel.swift
//  AuxBox
//
//  Created by Ivan Teo on 11/5/21.
//

import Foundation


public struct RoomModel : Codable{
    var roomName:String
    var currentQueue:[String]
    var nowPlaying:SongViewModel
    // just note their uid -- is this even necessary?
    var users:[String]
    var toQueue:[String]
    // normal queue is songs that haven't been queued
    // problem is that upon queueing, song will be removed
    // need a new variable to hold a queued song? or just not remove it? or put it in premium queue
    var normalQueue:[String]
    var geohash: String?
    var lat: Double?
    var lng: Double?
  
    enum CodingKeys: String, CodingKey {
        case roomName
        case currentQueue
        case nowPlaying
        case users
        case toQueue
        case normalQueue
        case geohash
        case lat
        case lng
    }

}
