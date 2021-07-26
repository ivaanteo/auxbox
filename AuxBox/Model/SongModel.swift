//
//  SongData.swift
//  AuxBox
//
//  Created by Ivan Teo on 29/4/21.
//

import Foundation

struct SongModel:Decodable {
    let tracks:Tracks
}

struct Tracks:Decodable{
    let items:[Items]
//    let error: PlaylistError
}

//struct PlaylistError:Decodable{
//    let status: Int
//    let message: String
//}

struct Track:Decodable{
    let name: String
    let album: Album
    let uri: String
    let artists: [Artists]
}

struct Items:Decodable{
    let album:Album?
    var artists:[Artists]?
    let name:String?
    var uri:String?
    var id: String?
    var images: [Images]?
    var track: Track?
}

struct Album:Decodable{
    let images:[Images]
}

struct Images:Decodable{
//    let height: Int
    let url: String
//    let width: Int
}

struct Artists:Decodable{
    let name:String
}

// for nowPlaying API call
struct NowPlayingModel:Decodable{
    var progress_ms:Int
    var item:Items
}

struct Playlist: Decodable{
//    var name:String
//    var imageURL:String
    let playlists: Playlists
}

struct Playlists: Decodable{
    let items:[Items]
}
