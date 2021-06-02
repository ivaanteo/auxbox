//
//  SearchManager.swift
//  AuxBox
//
//  Created by Ivan Teo on 28/4/21.
//

import Foundation

class SpotifySearchManager{
    
    func retrieveSearchResults(query: String, type: String, token: String, completed: @escaping (Result<[SongDetails], Error>) -> Void) -> Void {
        let limit = 15
        // headers
        let requestHeaders: [String:String] = [HeaderField.authorization : "Bearer \(token)",
                                               HeaderField.contentType : "application/json"]
        // setup url
        // check that url is valid first
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.spotify.com"
        components.path = "/v1/search"
        components.queryItems = [URLQueryItem(name: "q", value: query),
                                 URLQueryItem(name: "type", value: type),
                                 URLQueryItem(name: "limit", value: String(limit))]
        
        var request                 = URLRequest(url: components.url!)
        request.httpMethod          = "GET"
        request.allHTTPHeaderFields = requestHeaders
        // create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            switch (data, error) {
            case (_, let error?):
                completed(.failure(error))
            case (let data?, _):
                do {
                    let decoder                     = JSONDecoder()
                    decoder.keyDecodingStrategy     = .convertFromSnakeCase
                    let songResults = try decoder.decode(SongData.self, from: data)
                    
//                    var songDetails = [SongDetails]()
//                    songDetails.append(contentsOf: songResults.tracks.items.compactMap({ item in
//                        SongDetails(songName: item.name,
//                                    artist: item.artists[0].name,
//                                    image: item.album.images[0].url,
//                                    uri: item.uri)
//                        // maybe include a smaller image to save space
//                    }) )
                    let songDetails = songResults.tracks.items.compactMap({ item in
                                                SongDetails(songName: item.name,
                                                            artist: item.artists[0].name,
                                                            image: item.album.images[0].url,
                                                            uri: item.uri)})
                    // better to return an array of SongDetails to save memory
                    completed(.success(songDetails))
                } catch {
                    completed(.failure(error))
                }
            case (nil, nil):
                completed(.failure(error!))
            }
        }
        task.resume()
//        return RequestToken(task: task)
    }
}


