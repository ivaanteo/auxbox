//
//  NetworkManager.swift
//  AuxBox
//
//  Created by Ivan Teo on 28/4/21.
//

import UIKit

// final meaning you can't inherit
final class SpotifyAuthManager
{
    static let shared   = SpotifyAuthManager()
    private init() { }
    
    private let limit           = "50"
    private let offset          = "0"
    private let clientID        = "674cd699c32e453ca39240861f9b2a3f"
    private let encodedID  = "Njc0Y2Q2OTljMzJlNDUzY2EzOTI0MDg2MWY5YjJhM2Y6NjQ5NmRjZGFhNGJhNDQxYWIwMWU1NWMwZTc1OGNmNzE="
    let cache = NSCache<NSString, UIImage>()
    // For this you are required to Base64 Encode your Client ID
    // I recomend using this site https://www.base64encode.org/
    
    private let redirectUrl = "https%3A%2F%2Fwww.google.com%2F"
    
    
    private var clientAccessTokenExpirationDate:Date? {
        UserDefaults.standard.object(forKey: "clientAccessTokenExpirationDate") as? Date
    }
    
    private var shouldRefreshToken:Bool{
        guard let expirationDate = clientAccessTokenExpirationDate else {
            // we use refresh in a different sense
            // so if there's no expiration date to begin with, then just get a token!
            return true
        }
        // return true if current time is 5 mins away from expiration
        return Date().addingTimeInterval(300) >= expirationDate
    }
    
    
    func completeAuthorizeRequest(with endpoint: String, completed: @escaping (String?) -> Void)
    {
        var requestBodyComponents = URLComponents()
        let requestHeaders: [String:String] = [HeaderField.authorization : "Basic \(encodedID)",
                                               HeaderField.contentType : "application/x-www-form-urlencoded"]
        
        requestBodyComponents.queryItems = [URLQueryItem(name: HeaderField.grantType, value: "authorization_code"),
                                            URLQueryItem(name: HeaderField.code, value: endpoint),
                                            URLQueryItem(name: HeaderField.redirectUri, value: redirectUrl)]
        
        guard let url = URL(string: "\(SpotifyAPI.accountURL)api/token") else { return }
        var request                 = URLRequest(url: url)
        request.httpMethod          = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody            = requestBodyComponents.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let _            = error { print("completeAuthorizeRequest: error"); return }
//            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("completeAuthorizeRequest: response"); return }
            guard let response  = response as? HTTPURLResponse else { print("completeAuthorizeRequest: response"); return }
            guard let data      = data else { print("completeAuthorizeRequest: data"); return }
            
            do {
                let decoder                     = JSONDecoder()
                decoder.keyDecodingStrategy     = .convertFromSnakeCase
                let token                       = try decoder.decode(Token.self, from: data)
                print(token)
                PersistenceManager.saveAccessToken(accessToken: token.accessToken!)
                PersistenceManager.saveRefreshToken(refreshToken: token.refreshToken!)
                completed(token.accessToken!)
                return
            } catch {
                print("completeAuthorizeRequest: catch")
            }
        }
        task.resume()
    }
    
    func getClientAccessToken(completed: ((String?) -> Void)?){
        if shouldRefreshToken{
            print("client access token expired, getting new token")
            
            var requestBodyComponents = URLComponents()
            let requestHeaders: [String:String] = [HeaderField.authorization : "Basic \(encodedID)",
                                                   HeaderField.contentType : "application/x-www-form-urlencoded"]
            
            requestBodyComponents.queryItems = [URLQueryItem(name: HeaderField.grantType, value: "client_credentials")]
            
            guard let url = URL(string: "\(SpotifyAPI.accountURL)api/token") else { return }
            var request                 = URLRequest(url: url)
            request.httpMethod          = "POST"
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody            = requestBodyComponents.query?.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let _            = error { print("completeAuthorizeRequest: error"); return }
                //            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("completeAuthorizeRequest: response"); return }
                guard let response  = response as? HTTPURLResponse else { print("completeAuthorizeRequest: response"); return }
                guard let data      = data else { print("completeAuthorizeRequest: data"); return }
                
                
                do {
                    let decoder                     = JSONDecoder()
                    decoder.keyDecodingStrategy     = .convertFromSnakeCase
                    let clientToken                       = try decoder.decode(ClientToken.self, from: data)
                    
                    // saving encoded token
                    PersistenceManager.saveClientAccessToken(clientAccessToken: clientToken.accessToken!)
                    
                    // saving expiration date
                    if let expirationTime = clientToken.expiresIn{
                        UserDefaults.standard.setValue(Date().addingTimeInterval(Double(expirationTime)),
                                                       forKey: "clientAccessTokenExpirationDate")
                    }
                    
                    
                    // completion handler for accessToken
                    completed?(clientToken.accessToken!)
                    return
                } catch {
                    print("completeAuthorizeRequest: catch")
                }
            }
            task.resume()
        }else{
            completed?(PersistenceManager.retrieveClientAccessToken())
        }
    }
    
    func getRefreshToken(completed: @escaping (String?) -> Void)
    {
        // retrieve refresh token from userdefaults
        let refreshToken = PersistenceManager.retrieveRefreshToken()
        if refreshToken == "" { return }
        
        print("here")
        // headers
        let requestHeaders: [String:String] = [HeaderField.authorization : "Basic \(encodedID)",
                                               HeaderField.contentType : "application/x-www-form-urlencoded"]
        // parameters
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: HeaderField.grantType, value: "refresh_token"),
                                            URLQueryItem(name: HeaderField.refreshToken, value: refreshToken)]
        // perform api POST request
        guard let url = URL(string: "\(SpotifyAPI.accountURL)api/token") else { return }
        var request                 = URLRequest(url: url)
        request.httpMethod          = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody            = requestBodyComponents.query?.data(using: .utf8)
        
        // gotta swap current refresh token for a new one
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let _            = error { print("getRefreshToken: error"); return }
            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getRefreshToken: response"); return }
            guard let data      = data else { print("getRefreshToken: data"); return }
            
            do {
                let decoder                     = JSONDecoder()
                decoder.keyDecodingStrategy     = .convertFromSnakeCase
                let token                       = try decoder.decode(Token.self, from: data)
                
                PersistenceManager.saveAccessToken(accessToken: token.accessToken!)
                // closure takes in accesstoken
                completed(token.accessToken!)
                return
            } catch {
                print("getRefreshToken: catch");
            }
        }
        task.resume()
    }
    
    func startUserPlayback(){
        guard let url = URL(string: "\(SpotifyAPI.baseURL)me/player/play") else { print("could not create url"); return }
        
        var request         = URLRequest(url: url)
        request.httpMethod  = "PUT"
        request.addValue("Bearer \(PersistenceManager.retrieveAccessToken())", forHTTPHeaderField: HeaderField.authorization)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _            = error { print("start playback: error"); return }
            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("startUserPlayback Error"); return }
            guard let _      = data else { print("start playback: data"); return }
            
            print("complete playback")
            //            do {
            //                let decoder                 = JSONDecoder()
            //                decoder.keyDecodingStrategy = .convertFromSnakeCase
            //                let tracks                  = try decoder.decode(NewReleases.self, from: data)
            //
            //                completed(tracks); return
            //            } catch {
            //                print("getNewTrackRequest: catch")
            //            }
        }
        task.resume()
    }
    
    func getNowPlaying(){
        self.getRefreshToken { token in
            guard let token = token else { return }
            guard let url = URL(string: "\(SpotifyAPI.baseURL)me/player/currently-playing?market=SG") else {return}
            var request         = URLRequest(url: url)
            request.httpMethod  = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderField.authorization)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error            = error { print("getNowPlaying error: \(error)"); return }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { print("Queue Song Error"); return }
                guard let data      = data else { print("getNowPlaying error: data"); return }
                
                do {
                    let decoder                 = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let songData                  = try decoder.decode(NowPlayingModel.self, from: data)
                    print(songData.progress_ms)
                    print(songData.item.uri)
                    //                    completed(.success(songDetails));
                    return
                } catch {
                    print("getNowPlaying: catch")
                    //                    completed(.failure(.decodingError))
                }
            }
            task.resume()
        }
    }
    
    func getSongDetails(trackURI: String, completed: @escaping (Result<SongViewModel, NetworkError>) -> Void){
        guard let shortenedSongUri = trackURI.split(separator: ":").last else { return }
        self.getClientAccessToken { (token) in
            guard let token = token else { return }
            guard let url = URL(string: "\(SpotifyAPI.baseURL)tracks/\(shortenedSongUri)") else {return}
            
            var request         = URLRequest(url: url)
            request.httpMethod  = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderField.authorization)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let _ = error {
                    print("start playback: error")
                    completed(.failure(.requestError))
                    return }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("getSongDetails Error")
                    completed(.failure(.invalidResponse))
                    return }
                
                guard let data = data else {
                    print("start playback: data")
                    completed(.failure(.invalidData))
                    return }
                
                do {
                    let decoder                 = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let songData                  = try decoder.decode(Items.self, from: data)
//                    let songDetails = SongDetails(songName: songData.name,
//                                                  artist: songData.artists[0]?.name,
//                                                  image: songData.album?.images[0]?.url,
//                                                  uri: songData.uri!)
                    let songDetails = SongViewModel(songName: songData.name!, artist: songData.artists?[0].name ?? "", image: songData.album?.images[0].url ?? "", uri: songData.uri ?? "")
                    
                    print("fetch song details")
                    completed(.success(songDetails)); return
                } catch {
                    print("getNewTrackRequest: catch")
                    completed(.failure(.decodingError))
                }
            }
            task.resume()
        }
    }
    
    func getUserId(token: String, completed: @escaping (Result<String, NetworkError>) -> Void){
        // save to user defaults
        // check if already in user defaults
        
        // checks if id is not set yet. if set alr, just retrieve and return
        guard PersistenceManager.retrieveSpotifyID() == "" else { completed(.success(PersistenceManager.retrieveSpotifyID())); return }
        guard let url = URL(string: "\(SpotifyAPI.baseURL)me") else {return}
            var request         = URLRequest(url: url)
            request.httpMethod  = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderField.authorization)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let _ = error {
                    print("start playback: error")
                    completed(.failure(.requestError))
                    return }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("getSongDetails Error")
                    completed(.failure(.invalidResponse))
                    return }
                
                guard let data = data else {
                    print("start playback: data")
                    completed(.failure(.invalidData))
                    return }
                
                do {
                    let decoder                 = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let spotifyId  = try decoder.decode(SpotifyUserModel.self, from: data)
                    
                    print("fetch user profile")
                    completed(.success(spotifyId.id))
                    return
                } catch {
                    print("getNewTrackRequest: catch")
                    completed(.failure(.decodingError))
                }
            }
            task.resume()
    }
    
    func getUserPlaylists(pageNumber: Int, completed: @escaping (Result<[PlaylistViewModel], NetworkError>) -> Void){
        let limit = 20
        let offset = pageNumber * limit
        
        self.getRefreshToken { (token) in
            guard let token = token else { return }
            self.getUserId(token: token) { (res) in
                switch res{
                case .success(let userId):
                    guard let url = URL(string: "\(SpotifyAPI.baseURL)users/\(userId)/playlists?limit=\(limit)&offset=\(offset)") else {return}
//                    guard let url = URL(string: "\(SpotifyAPI.baseURL)me/playlists?limit=\(limit)") else {return}
                    var request         = URLRequest(url: url)
                    request.httpMethod  = "GET"
                    request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderField.authorization)
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let _ = error {
                            print("start playback: error")
                            completed(.failure(.requestError))
                            return }
                        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                            print("getSongDetails Error")
                            completed(.failure(.invalidResponse))
                            return }
                        
                        guard let data = data else {
                            print("start playback: data")
                            completed(.failure(.invalidData))
                            return }
                        
                        do {
                            let decoder                 = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let playlistData                  = try decoder.decode(Playlists.self, from: data)
                            let playlistDetails = playlistData.items.compactMap({ item in
                                PlaylistViewModel(name: item.name!, imgURL: item.images?[0].url, playlistID: item.id ?? "")
                            })
                            
                            print("fetch song details")
                            completed(.success(playlistDetails)); return
                        } catch {
                            print("getNewTrackRequest: catch")
                            completed(.failure(.decodingError))
                        }
                    }
                    task.resume()
                case .failure(let err):
                    print("Error getting user id: \(err.localizedDescription)")
                    completed(.failure(err))
                }
            }
        }
    }
    
    func getFeaturedPlaylists(numberOfPlaylists limit: Int, completed: @escaping (Result<[PlaylistViewModel], NetworkError>) -> Void){
        self.getClientAccessToken { (token) in
            guard let url = URL(string: "\(SpotifyAPI.baseURL)browse/featured-playlists?country=SG&limit=\(limit)") else {return}
            guard let token = token else {return}
            var request         = URLRequest(url: url)
            request.httpMethod  = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderField.authorization)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let _ = error {
                    print("start playback: error")
                    completed(.failure(.requestError))
                    return }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("getSongDetails Error")
                    completed(.failure(.invalidResponse))
                    return }
                
                guard let data = data else {
                    print("start playback: data")
                    completed(.failure(.invalidData))
                    return }
                
                do {
                    let decoder                 = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let playlistData                  = try decoder.decode(Playlist.self, from: data)
                    
                    
                    let playlistDetails = playlistData.playlists.items.compactMap({ item in
                        PlaylistViewModel(name: item.name!, imgURL: item.images?[0].url, playlistID: item.id ?? "")
                    })
                    
                    print("fetch song details")
                    completed(.success(playlistDetails)); return
                } catch {
                    print("getNewTrackRequest: catch")
                    completed(.failure(.decodingError))
                }
            }
            task.resume()
        }
    }
    
    func getPlaylistDetails(playlistID:String, market: String, pageNumber: Int = 0, completed: @escaping (Result<[SongViewModel], NetworkError>) -> Void){
        // default limit = 100
        let limit = 100
        let offset = pageNumber * limit
        self.getClientAccessToken { (token) in
        guard let url = URL(string: "\(SpotifyAPI.baseURL)playlists/\(playlistID)/tracks?market=\(market)&limit=\(limit)&offset=\(offset)") else {return}
        guard let token = token else {return}
        var request         = URLRequest(url: url)
        request.httpMethod  = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderField.authorization)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                print("start playback: error")
                completed(.failure(.requestError))
                return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("getSongDetails Error")
                completed(.failure(.invalidResponse))
                return }
            
            guard let data = data else {
                print("start playback: data")
                completed(.failure(.invalidData))
                return }
            
            do {
                let decoder                 = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let songData                  = try decoder.decode(Tracks.self, from: data)
                let songDetails = songData.items.compactMap({ item in
                    SongViewModel(songName: item.track?.name ?? "", artist: item.track?.artists[0].name ?? "", image: item.track?.album.images[0].url ?? "", uri: item.track?.uri ?? "")
                })
                
                print("fetch song details")
                completed(.success(songDetails)); return
            } catch {
                print("getNewTrackRequest: catch")
                completed(.failure(.decodingError))
            }
        }
        task.resume()
        }
    }
    
    //    private func fetchData<T: Codable>(token: String, url: String, completed: @escaping (Result<T, NetworkError>) -> Void ){
    //
    //
    //    }
    
    func queueSongs(with queueList:[String]){
        self.getRefreshToken { token in
            guard let token = token else { return }
            for uri in queueList{
                self.queueSong(uri: uri, token)
            }
        }
    }
    
    func normalQueueSong(uri: String){
        self.getRefreshToken { (token) in
            guard let token = token else { return }
            self.queueSong(uri: uri, token)
        }
    }
    
    private func queueSong(uri: String,_ token: String){
        guard let url = URL(string: "\(SpotifyAPI.baseURL)me/player/queue?uri=\(uri)") else {return}
        var request         = URLRequest(url: url)
        request.httpMethod  = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderField.authorization)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error            = error { print("queueSong error: \(error)"); return }
            guard let unwrappedResponse  = response as? HTTPURLResponse else { print("Queue Song Error"); return }
            print("unwrappedResponse \(unwrappedResponse)")
            //            guard let data      = data else { print("start playback: data"); return }
        }
        task.resume()
    }
    
    func downloadImage(from urlString: String, defaultImage: UIImage = UIImage(systemName: "music.note")!, key: String = "k", completed: @escaping (UIImage?) -> Void)
    {
        var cacheKey: NSString?
        if key == "k"{
            // if no key input, use the url string as the key
            cacheKey = NSString(string: urlString)
        }else{
            // if theres a key input, use the key input as the key
            cacheKey = NSString(string: key)
        }
//        let cacheKey    = NSString(string: urlString)
        // here we check if image has been cached
        if let image    = cache.object(forKey: cacheKey!) {print("used cache"); completed(image);return }
//        else if key != "k"{
//            print("use default image")
//            completed(defaultImage); return
//        }
        guard let url = URL(string: urlString) else {print("failed to parse url"); completed(defaultImage); return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let response    = response as? HTTPURLResponse, response.statusCode == 200,
                  let data        = data,
                  let image       = UIImage(data: data) else { print("failed to create image"); completed(defaultImage); return }
            
            self.cache.setObject(image, forKey: cacheKey!)
            print("successfully cached img")
            completed(image)
        }
        task.resume()
    }
}

//func fetchArtwork(for track: SPTAppRemoteTrack) {
//        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
//            if let error = error {
//                print("Error fetching track image: " + error.localizedDescription)
//            } else if let image = image as? UIImage {
//                // set image to artwork
//                print("setted image to artwork")
//            }
//        })
//    }


//
//    // MARK: - PLAYLIST DATA
//
//    func createPlaylist(OAuthtoken: String, playlistName: String, playlistDescription: String, songs: [String], isPublic: String, completed: @escaping (String?) -> Void)
//    {
//        guard let urlUser = URL(string: "\(baseURL.spotifyAPI)v1/me") else { print("urlUser"); return }
//
//        var requestUser         = URLRequest(url: urlUser)
//        requestUser.httpMethod  = "GET"
//        requestUser.addValue("application/json", forHTTPHeaderField: HeaderField.accept)
//        requestUser.addValue("application/json", forHTTPHeaderField: HeaderField.contentType)
//        requestUser.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: HeaderField.authorization)
//
//        let taskUserID = URLSession.shared.dataTask(with: requestUser) { data, response, error in
//
//            if let _            = error { print("taskUserID: error"); return }
//            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("taskUserID: response"); return }
//            guard let data      = data else { print("taskUserIDL: data"); return }
//
//            do {
//                let decoder                 = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let user                    = try decoder.decode(UserProfile.self, from: data)
//
//                guard let uid = user.id else { return }
//                guard let urlPlaylist = URL(string: "\(baseURL.spotifyAPI)v1/users/\(uid)/playlists") else { print("urlPlaylist"); return }
//
//                let requestPlaylistHeaders: [String:String] = [HeaderField.accept : "application/json",
//                                                               HeaderField.contentType : "application/json",
//                                                               HeaderField.authorization : "Bearer \(OAuthtoken)"]
//
//                let parametersPlaylist: [String: Any] = [
//                    "name" : playlistName,
//                    "description" : playlistDescription,
//                    "public": false
//                ]
//
//                let jsonPlaylistData = try? JSONSerialization.data(withJSONObject: parametersPlaylist)
//
//                var requestPlaylist                 = URLRequest(url: urlPlaylist)
//                requestPlaylist.httpMethod          = "POST"
//                requestPlaylist.allHTTPHeaderFields = requestPlaylistHeaders
//                requestPlaylist.httpBody            = jsonPlaylistData
//
//                let taskPlaylist = URLSession.shared.dataTask(with: requestPlaylist) { data, response, error in
//
//                    if let _        = error { return }
//                    guard let data  = data else { return } /// no error code, bc returns error object
//
//                    do {
//                        let decoder                 = JSONDecoder()
//                        decoder.keyDecodingStrategy = .convertFromSnakeCase
//                        let playlist                = try decoder.decode(Playlist.self, from: data)
//
//                        guard let playlistID = playlist.id else { return }
//                        guard let urlSongs = URL(string: "\(baseURL.spotifyAPI)v1/playlists/\(playlistID)/tracks") else { print("urlSongs"); return }
//
//                        let requestSongsHeaders: [String:String] = [HeaderField.accept : "application/json",
//                                                                    HeaderField.contentType : "application/json",
//                                                                    HeaderField.authorization : "Bearer \(OAuthtoken)"]
//
//                        let parametersSongs: [String: Any] = ["uris" : songs]
//                        let jsonSongsData = try? JSONSerialization.data(withJSONObject: parametersSongs)
//
//                        var requestSongs                 = URLRequest(url: urlSongs)
//                        requestSongs.httpMethod          = "POST"
//                        requestSongs.allHTTPHeaderFields = requestSongsHeaders
//                        requestSongs.httpBody            = jsonSongsData
//
//                        let taskSongs = URLSession.shared.dataTask(with: requestSongs) { data, response, error in
//
//                            if let _        = error { print("taskSongs: error"); return }
//                            guard let data  = data else { print("taskSongs: data"); return }
//
//                            do {
//                                let decoder                 = JSONDecoder()
//                                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                                let snapshot                = try decoder.decode(Snapshot.self, from: data)
//                                completed(snapshot.snapshotId); return
//                            } catch { print("taskSongs: catch") }
//                        }
//                        taskSongs.resume()
//                    } catch { print("taskPlaylist: catch") }
//                }
//                taskPlaylist.resume()
//            } catch { print("taskUserID: catch") }
//        }
//        taskUserID.resume()
//    }
//
//    // MARK: - FETCH MUSIC DATA
//
//    func getArtistRequest(OAuthtoken: String, completed: @escaping (ArtistItem?) -> Void)
//    {
//        let type        = "artists"
//        let timeRange   = "long_term"
//
//        guard let url = URL(string: "\(baseURL.spotifyAPI)v1/me/top/\(type)?time_range=\(timeRange)&limit=\(limit)&offset=\(offset)") else { print("getArtistRequest: url"); return }
//
//        var request         = URLRequest(url: url)
//        request.httpMethod  = "GET"
//        request.addValue("application/json", forHTTPHeaderField: HeaderField.accept)
//        request.addValue("application/json", forHTTPHeaderField: HeaderField.contentType)
//        request.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: HeaderField.authorization)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            if let _            = error { print("getArtistRequest: error"); return }
//            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getArtistRequest: response"); return }
//            guard let data      = data else { print("getArtistRequest: data"); return }
//
//            do {
//                let decoder                 = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let artists                 = try decoder.decode(ArtistItem.self, from: data)
//
//                completed(artists)
//                return
//            } catch {
//                print("getArtistRequest: catch");
//            }
//        }
//        task.resume()
//    }
//
//    func getTrackRequest(OAuthtoken: String, completed: @escaping (TrackItem?) -> Void)
//    {
//        let type        = "tracks"
//        let timeRange   = "long_term"
//
//        guard let url = URL(string: "\(baseURL.spotifyAPI)v1/me/top/\(type)?time_range=\(timeRange)&limit=\(limit)&offset=\(offset)") else { print("getTrackRequest: url"); return }
//
//        var request         = URLRequest(url: url)
//        request.httpMethod  = "GET"
//        request.addValue("application/json", forHTTPHeaderField: HeaderField.accept)
//        request.addValue("application/json", forHTTPHeaderField: HeaderField.contentType)
//        request.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: HeaderField.authorization)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            if let _            = error { print("getTrackRequest: error:"); return }
//            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getTrackRequest: response:"); return }
//            guard let data      = data else { print("getTrackRequest: data:"); return }
//
//            do {
//                let decoder                 = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let tracks                  = try decoder.decode(TrackItem.self, from: data)
//
//                completed(tracks); return
//            } catch {
//                print("getTrackRequest: catch")
//            }
//        }
//        task.resume()
//    }
//
//    func getRecentTracks(OAuthtoken: String, completed: @escaping (TrackItem?) -> Void)
//    {
//        let type        = "tracks"
//        let timeRange   = "short_term" /// 4 weeks
//        let limit       = "50"
//
//        guard let url = URL(string: "\(baseURL.spotifyAPI)v1/me/top/\(type)?time_range=\(timeRange)&limit=\(limit)&offset=\(offset)") else { print("getRecentTracks: url"); return }
//
//        var request         = URLRequest(url: url)
//        request.httpMethod  = "GET"
//        request.addValue("application/json", forHTTPHeaderField: HeaderField.accept)
//        request.addValue("application/json", forHTTPHeaderField: HeaderField.contentType)
//        request.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: HeaderField.authorization)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            if let _            = error { print("getRecentTracks: error"); return }
//            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getRecentTracks: response"); return }
//            guard let data      = data else { print("getRecentTracks: data"); return }
//
//            do {
//                let decoder                 = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let tracks                  = try decoder.decode(TrackItem.self, from: data)
//
//                completed(tracks); return
//            } catch {
//                print("getRecentTracks: url")
//            }
//        }
//        task.resume()
//    }
//
//    func getNewTrackRequest(OAuthtoken: String, completed: @escaping (NewReleases?) -> Void)
//    {
//        guard let url = URL(string: "\(baseURL.spotifyAPI)v1/browse/new-releases?country=US") else { print("getNewTrackRequest: url"); return }
//
//        var request         = URLRequest(url: url)
//        request.httpMethod  = "GET"
//        request.addValue("application/json", forHTTPHeaderField: HeaderField.accept)
//        request.addValue("application/json", forHTTPHeaderField: HeaderField.contentType)
//        request.addValue("Bearer \(String(OAuthtoken))", forHTTPHeaderField: HeaderField.authorization)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            if let _            = error { print("getNewTrackRequest: error"); return }
//            guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else { print("getNewTrackRequest: response"); return }
//            guard let data      = data else { print("getNewTrackRequest: data"); return }
//
//            do {
//                let decoder                 = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let tracks                  = try decoder.decode(NewReleases.self, from: data)
//
//                completed(tracks); return
//            } catch {
//                print("getNewTrackRequest: catch")
//            }
//        }
//        task.resume()
//    }
//
//    // MARK: - DOWNLOAD IMAGES
//
//    func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void)
//    {
//        let cacheKey    = NSString(string: urlString)
//        if let image    = cache.object(forKey: cacheKey) { completed(image); return }
//        guard let url   = URL(string: urlString) else { return }
//
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//
//            guard let self = self,
//                error == nil,
//                let response    = response as? HTTPURLResponse, response.statusCode == 200,
//                let data        = data,
//                let image       = UIImage(data: data) else { return }
//
//            self.cache.setObject(image, forKey: cacheKey)
//            completed(image)
//        }
//        task.resume()
//    }
//}
