//
//  SongData.swift
//  AuxBox
//
//  Created by Ivan Teo on 29/4/21.
//

import Foundation

struct SongData:Decodable {
    let tracks:Tracks
}

struct Tracks:Decodable{
    let items:[Items]
}

struct Items:Decodable{
    let album:Album
    let artists:[Artists]
    let name:String
    let uri:String
}

struct Album:Decodable{
    let images:[Images]
}

struct Images:Decodable{
    let height: Int
    let url: String
    let width: Int
}

struct Artists:Decodable{
    let name:String
}

// for nowPlaying API call
struct NowPlayingModel:Decodable{
    var progress_ms:Int
    var item:Items
}
