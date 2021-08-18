//
//  AuxCodeManager.swift
//  AuxBox
//
//  Created by Ivan Teo on 9/5/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import GeoFire

class DatabaseManager{
//    static var connectedToAuxCode:String = ""
//    static var connectedToRoomName:String = ""
    
//    static var roomDetails:Room? = nil
//    static var user: UserDetails? = nil
    
    var roomDetails:RoomModel? = nil
    var user: UserDetails? = nil
    
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    static var listener : ListenerRegistration?
    
    var locationManager: CLLocationManager {
        get{
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)!.locationManager
        }
    }
    
    
    // MARK: User Functions
    
//    func saveUser(user: User, completed: @escaping (String?) -> Void){
    func saveUser(user: User, completed: @escaping (UserDetails?) -> Void){
//        guard let profilePic = user.photoURL?.absoluteString else { return }
        guard let displayName = user.displayName else { print("no name"); return }
//        let displayName = user.displayName ?? "No Name"
        // right now, facebook doesn't allow email so use uid instead
        let email = user.email ?? user.uid
//        guard let email = user.email else { return }
        
        let usersRef = self.db.collection(K.FStore.usersCollection).document(user.uid)
        usersRef.getDocument { (document, error) in
            guard error == nil else { return }
//            guard DatabaseManager.shared.user == nil else {
//                // account exists and all's good
//                completed(DatabaseManager.shared.user)
//                return
//            }
            // this happens when account exists but first time logging in
            if let document = document, document.exists {
                // check if user UID exists
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
//                print("Document data: \(dataDescription)")
                do{
                    let userDetails = try document.data(as: UserDetails.self)
                    DatabaseManager.shared.user = userDetails
                    completed(userDetails)
                }catch{
                    completed(nil)
                }
            } else {
                // no account created yet
                let auxCode = self.getVerifiedAuxCode()
                let userDetails = UserDetails(name: displayName,
                                              email: email,
                                              profilePictureURL: user.photoURL?.absoluteString,
                                              auxCode: auxCode,
                                              joinedRoom: nil,
                                              credits: 2
                )
                DatabaseManager.shared.user = userDetails
                do{
                    try usersRef.setData(from: userDetails)
                    completed(userDetails)
                }catch let error{
                    print(error.localizedDescription)
                    completed(nil)
                    return
                }
                
                // try to throw error
                print("Document does not exist, stored UID")
                // save to userDefaults
                UserDefaults.standard.set(auxCode, forKey: K.SpotifyKeys.auxCodeKey)
            }
            
        }
    }
    
    func updateUserProfile(user: UserDetails, completed: @escaping ((Result<Void, NetworkError>) -> ()) ){
        guard let uid = Auth.auth().currentUser?.uid else { completed(.failure(.invalidAccount)); return }
        let userRef = db.collection(K.FStore.usersCollection).document(uid)
        let batch = db.batch()
        if let name = user.name{
            batch.updateData(["name": name], forDocument: userRef)
        }
        if let profilePicURL = user.profilePictureURL{
            batch.updateData(["profilePictureURL": profilePicURL], forDocument: userRef)
        }
        batch.commit(){ err in
            guard err == nil else {
                completed(.failure(.requestError))
                return
            }
            completed(.success(()))
        }
    }
    
    func addDatabaseListener(auxCode: String, completed: @escaping (RoomModel?) -> Void){
        DatabaseManager.listener = db.collection(K.FStore.roomsCollection).document(auxCode)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    completed(nil)
                    return
                }
                let result = Result {
                    try document.data(as: RoomModel.self)
                }
                switch result {
                case .success(let room):
                    if let room = room {
                        // A `City` value was successfully initialized from the DocumentSnapshot.
                        completed(room)
                    } else {
                        // A nil value was successfully initialized from the DocumentSnapshot,
                        // or the DocumentSnapshot was nil.
                        print("Document does not exist")
                        completed(nil)
                    }
                case .failure(let error):
                    // A `City` value could not be initialized from the DocumentSnapshot.
                    print("Error decoding room: \(error)")
                    completed(nil)
                }
                return
            }
    }
    
    func removeDatabaseListener(){
        DatabaseManager.listener?.remove()
    }
    
    
    func fetchData<T: Codable>(collection: String, document: String, type: T.Type ,completed: @escaping (Result<T, NetworkError>)->Void){
        db.collection(collection).document(document).getDocument { (document, err) in
            let result = Result{
                try document?.data(as: type)
            }
            switch result {
            case .success(let data):
                if let data = data {
                    // A `room` value was successfully initialized from the DocumentSnapshot.
                    //cache as global variable
                    completed(.success(data))
                } else {
                    // A nil value was successfully initialized from the DocumentSnapshot,
                    // or the DocumentSnapshot was nil.
                    print("Document does not exist")
                    completed(.failure(.invalidData))
                }
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding data: \(error)")
                completed(.failure(.decodingError))
            }
        }
    }
    
    func purchaseCoins(coins: Double, completed: @escaping (Result<Void, NetworkError>) -> ()){
        guard let uid = Auth.auth().currentUser?.uid else { completed(.failure(.invalidAccount)); return }
        // increase credit
        db.collection(K.FStore.usersCollection).document(uid).updateData(["credits": FieldValue.increment(coins)]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                completed(.failure(.requestError))
            } else {
                print("updateUserRoom successfully updated")
                self.user?.credits += Int(coins)
                completed(.success(()))
            }
        }
    }
    
    
    func getConnectedToAux(userUID: String, completed: @escaping (String?) -> Void){
        //        guard let userUID = Auth.auth().currentUser?.uid else{return}
        db.collection(K.FStore.usersCollection).document(userUID).getDocument { (document, err) in
            let result = Result {
                try document?.data(as: UserDetails.self)
            }
            switch result {
            case .success(let user):
                if let user = user {
                    // A `City` value was successfully initialized from the DocumentSnapshot.
                    completed(user.joinedRoom)
                } else {
                    // A nil value was successfully initialized from the DocumentSnapshot,
                    // or the DocumentSnapshot was nil.
                    print("Document does not exist")
                    completed(nil)
                }
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding city: \(error)")
                completed(nil)
            }
        }
    }
    
    
    
    func getRoomDetails(auxCode:String, completed: @escaping (Result<RoomModel, NetworkError>) -> Void){
        db.collection(K.FStore.roomsCollection).document(auxCode).getDocument { (document, err) in
            let result = Result {
                try document?.data(as: RoomModel.self)
            }
            
//            do{
//                let result = Result{ try document?.data(as: Room.self)}
//                completed(result)
//            }
//
//            completed()
            
            switch result {
            case .success(let room):
                if let room = room {
                    // A `room` value was successfully initialized from the DocumentSnapshot.
                    //cache as global variable
//                    DatabaseManager.connectedToAuxCode = auxCode
                    DatabaseManager.shared.user?.joinedRoom = auxCode
                    DatabaseManager.shared.roomDetails = room
                    completed(.success(room))
                
                } else {
                    // A nil value was successfully initialized from the DocumentSnapshot,
                    // or the DocumentSnapshot was nil.
                    print("Document does not exist")
                    completed(.failure(.invalidData))
                }
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding city: \(error)")
                completed(.failure(.decodingError))
            }
        }
    }
    
//    func getRoomDetails(auxCode:String, completed: @escaping (Room?) -> Void){
//        db.collection(K.FStore.roomsCollection).document(auxCode).getDocument { (document, err) in
//            let result = Result {
//                try document?.data(as: Room.self)
//            }
//            switch result {
//            case .success(let room):
//                if let room = room {
//                    // A `room` value was successfully initialized from the DocumentSnapshot.
//                    //cache as global variable
//                    DatabaseManager.connectedToAuxCode = auxCode
//                    DatabaseManager.roomDetails = room
//                    completed(room)
//                } else {
//                    // A nil value was successfully initialized from the DocumentSnapshot,
//                    // or the DocumentSnapshot was nil.
//                    print("Document does not exist")
//                    completed(nil)
//                }
//            case .failure(let error):
//                // A `City` value could not be initialized from the DocumentSnapshot.
//                print("Error decoding city: \(error)")
//                completed(nil)
//            }
//        }
//    }
    
    func updateUserRoom(auxCode: String){
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        let usersRef = self.db.collection(K.FStore.usersCollection).document(userUID)
        //        usersRef.setData(["joinedRoom": auxCode], merge: true)
        // cache as global variable
        
        DatabaseManager.shared.user?.joinedRoom = auxCode
        usersRef.updateData(["joinedRoom": auxCode]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("updateUserRoom successfully updated")
            }
        }
    }
    
    // Credits Transacted Here
    func updateRoomToQueue(uri: String, isPremiumQueue: Bool, recipientUID: String? = nil, completed: @escaping (Result<String, Error>)->Void){
        guard let auxCode = DatabaseManager.shared.user?.joinedRoom else {return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        
        let dataToUpdate = isPremiumQueue ? ["toQueue" : FieldValue.arrayUnion([uri])] : ["normalQueue" : FieldValue.arrayUnion([uri])]
        
        if isPremiumQueue{
            // batch update for credits
            let batch = db.batch()
            batch.updateData(dataToUpdate, forDocument: roomRef)
            guard let ownUID = Auth.auth().currentUser?.uid else { return }
            let ownUserRef = db.collection(K.FStore.usersCollection).document(ownUID)
            guard let recipientUID = recipientUID else { return }
            let recipientUserRef = db.collection(K.FStore.usersCollection).document(recipientUID)
            batch.updateData(["credits" : FieldValue.increment(Double(-1))], forDocument: ownUserRef)
            batch.updateData(["credits" : FieldValue.increment(Double(1))], forDocument: recipientUserRef)
            
            // here, update transaction collection with credits
            let transactionsRef = db.collection(K.FStore.transactionsCollection).document()
            print("timeIntervalSince1970 \(Date().timeIntervalSince1970)")
            let time = Date().timeIntervalSince1970
            let txn = TransactionModel(songURI: uri, timestamp: time, sender: ownUID, recipient: recipientUID)
            do{
                try batch.setData(from: txn, forDocument: transactionsRef)
            }catch{
                print("error setting data \(error.localizedDescription)")
            }

            batch.commit(){ err in
                if let error = err {
                    completed(.failure(error))
                }else{
                    completed(.success(K.Texts.queuedSongText))
                }
            }
        }else{
            // normal queue, just add to normalQueue
            roomRef.updateData(dataToUpdate){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    completed(.failure(err))
                } else {
                    completed(.success(K.Texts.queuedSongText))
                }
            }
        }
    }
    
    func fetchTransactions(isHost: Bool, completed: @escaping (Result<[TransactionViewModel], NetworkError>) -> Void){
        guard let ownUID = Auth.auth().currentUser?.uid else { return }
        let transactionsRef = isHost ? db.collection(K.FStore.transactionsCollection).whereField("recipient", isEqualTo: ownUID).order(by: "timestamp", descending: true) : db.collection(K.FStore.transactionsCollection).whereField("sender", isEqualTo: ownUID).order(by: "timestamp", descending: true)
    
        let group = DispatchGroup()
        transactionsRef.getDocuments { (snapshot, err) in
            guard err == nil else {
                print("Error getting documents: \(String(describing: err?.localizedDescription))")
                completed(.failure(.invalidResponse))
                return
            }
            
            let transactionsList = snapshot?.documents.map({ (doc) -> TransactionViewModel in
                var transaction: TransactionViewModel?
                do{
                    let model = try doc.data(as: TransactionModel.self)
                    group.enter()
                    SpotifyAuthManager.shared.getSongDetails(trackURI: model!.songURI) { (res) in
                        switch res{
                        case .success(let song):
                            let date = Date(timeIntervalSince1970: model!.timestamp)
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            let dateString = dateFormatter.string(from: date)
                            transaction = TransactionViewModel(date: dateString, songName: song.songName, artist: song.artist)
                            group.leave()
                        case .failure:
                            print("error getting song details")
                            transaction = TransactionViewModel(date: "-", songName: "-", artist: "-")
                            group.leave()
                        }
                    }
                }catch{
                    print("error decoding data \(error.localizedDescription)")
                    transaction = TransactionViewModel(date: "-", songName: "-", artist: "-")
                    group.leave()
                }
                group.wait()
                return transaction!
            })
            completed(.success(transactionsList!))
        }
        
    }
    
    func updateEntireRoom(room: RoomModel){
        guard let auxCode = DatabaseManager.shared.user?.auxCode else { return }
        do{
            try db.collection(K.FStore.roomsCollection).document(auxCode).setData(from: room)
        }catch let error{
            print(error.localizedDescription)
            return
        }
    }
    
    func updateRoomUsers(auxCode:String, create: Bool){
        guard let userUID = Auth.auth().currentUser?.uid else{ print("error getting current user"); return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        if create{
            roomRef.updateData(["users" : FieldValue.arrayUnion([userUID])])
        }else{
            roomRef.updateData(["users" : FieldValue.arrayRemove([userUID])])
        }
    }
    
    func didQueueSongs(queueList : [String]){
        guard let auxCode = DatabaseManager.shared.user?.auxCode else {return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        guard let currentQueue = DatabaseManager.shared.roomDetails?.currentQueue else { return }
        var updatedCurrentQueue = currentQueue
        for uri in queueList{
            updatedCurrentQueue.append(uri)
        }
        roomRef.updateData(["currentQueue" : updatedCurrentQueue, "toQueue" : FieldValue.arrayRemove(queueList)])
        // update credits here bc might as well
        // should follow database, but not foolproof
        DatabaseManager.shared.user?.credits += queueList.count
//        roomRef.updateData(["toQueue" : FieldValue.arrayRemove(queueList)])
    }
    
    func didNormalQueueSong(uri: String){
        guard let auxCode = DatabaseManager.shared.user?.auxCode else {return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        guard var currentQueue = DatabaseManager.shared.roomDetails?.currentQueue else { return }
        currentQueue.append(uri)
        // this updates the current queue, removes from normal queue
        roomRef.updateData(["currentQueue" : currentQueue, "normalQueue" : FieldValue.arrayRemove([uri])])
    }
    
    
    
    func updateRoomCurrentQueue(songURIToRemove: String){
        guard let auxCode = DatabaseManager.shared.user?.auxCode else {return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        roomRef.updateData(["currentQueue" : FieldValue.arrayRemove([songURIToRemove])])
    }
    
    func updateRoomNowPlaying(nowPlaying: SongViewModel){
        guard let auxCode = DatabaseManager.shared.user?.auxCode else { return }
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        roomRef.updateData(["nowPlaying.songName" : nowPlaying.songName,
                            "nowPlaying.artist" : nowPlaying.artist,
                            "nowPlaying.image" : nowPlaying.image
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("updateRoomNowPlaying successfully updated")
            }
        }
    }
    
    func batchStartActiveRoom(room: RoomModel){
        // should create a room and update user's joined room property to his own auxcode
        let batch = db.batch()
        
        // create room
        guard let auxCode = DatabaseManager.shared.user?.auxCode else { return }
        let roomRef = db.collection(K.FStore.roomsCollection).document(auxCode)
        do {
            try batch.setData(from: room, forDocument: roomRef)
            DatabaseManager.shared.roomDetails = room
        } catch {
            print("Error setting room \(error.localizedDescription)")
        }
        
        // update user's room
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        let usersRef = self.db.collection(K.FStore.usersCollection).document(userUID)
        batch.updateData(["joinedRoom": auxCode], forDocument: usersRef)
        DatabaseManager.shared.user?.joinedRoom = auxCode
        
        
        batch.commit() { err in
            if let err = err{
                print("Error with batch start active room \(err.localizedDescription)")
            }else{
                print("Batch create room succeeded")
            }
        }
    }
    
    func batchJoinRoom(auxCode: String, room: RoomModel?, exitRoom: Bool, completed: @escaping (Error?) -> Void){
        guard let userUID = Auth.auth().currentUser?.uid else{ print("error getting current user"); return}
        
        
        let batch = db.batch()
        
        // update room's users
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        let userRef = self.db.collection(K.FStore.usersCollection).document(userUID)
        if exitRoom{
            // exit room, delete uid from room's list of users
            print("userUID: \(userUID)")
            batch.updateData(["users" : FieldValue.arrayRemove([userUID])], forDocument: roomRef)
            // remove joined room
            batch.updateData(["joinedRoom" : FieldValue.delete()], forDocument: userRef)
            DatabaseManager.shared.user?.joinedRoom = nil
            DatabaseManager.shared.roomDetails = nil
        }else{
            // join room, add uid to room's list of users
            batch.updateData(["users" : FieldValue.arrayUnion([userUID])], forDocument: roomRef)
            // add room's auxcode to user's joined room
            batch.updateData(["joinedRoom" : auxCode], forDocument: userRef)
            // update local state
            DatabaseManager.shared.user?.joinedRoom = auxCode
            DatabaseManager.shared.roomDetails = room!
        }
        
        batch.commit(){ err in
            if let err = err{
                completed(err)
                print("Failed to batch join room \(err.localizedDescription)")
            }else{
                completed(nil)
                print("Batch join room success")
            }
        }
    }
    
    func startActiveRoom(room: RoomModel){
        // don't need to check that room exists since you're setting data, not creating another collection
        guard let auxCode = DatabaseManager.shared.user?.auxCode else { return }
        do{
            try db.collection(K.FStore.roomsCollection).document(auxCode).setData(from: room)
        }catch let error{
            print(error.localizedDescription)
            return
        }
        print("did update active room")
        DatabaseManager.shared.roomDetails = room
    }
    
    func deleteActiveRoom(){
        guard let auxCode = DatabaseManager.shared.user?.auxCode else { return }
        db.collection(K.FStore.roomsCollection).document(auxCode).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func deleteJoinedRoom(){
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        let usersRef = self.db.collection(K.FStore.usersCollection).document(userUID)
        usersRef.updateData([
            "joinedRoom": FieldValue.delete(),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        DatabaseManager.shared.roomDetails = nil
        DatabaseManager.shared.user?.joinedRoom = nil
    }
    
    
//    func retrieveAuxCode() -> String{
//        guard let auxCode = UserDefaults.standard.object(forKey: K.SpotifyKeys.auxCodeKey) as? String else{ return "" }
//        return auxCode
//    }
    
    
    
    private func getVerifiedAuxCode() -> String{
        var auxCode = generateAuxCode(of: 6)
        let usersRef = db.collection(K.FStore.usersCollection)
        // check that aux code is non-existent
        usersRef.whereField(K.FStore.auxCodeField, isEqualTo: auxCode).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot!.documents != []{
                    auxCode = self.getVerifiedAuxCode()
                }
                // document doesn't exist, so you can return aux code alr
            }
        }
        return auxCode
    }
    
    private func generateAuxCode(of length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var s = ""
        for _ in 0 ..< length {
            s.append(letters.randomElement()!)
        }
        return s
    }
    
    
    // GeoFire
    
    func updateLocation(location: CLLocation){
        var distance:Double = 351
    
        
        if let oldLat = roomDetails?.lat, let oldLng = roomDetails?.lng{
            let oldLocation = CLLocation(latitude: oldLat, longitude: oldLng)
            distance = location.distance(from: oldLocation)
        }

        // update database when distance changes by 250m
        if distance > 350{
            let coordinates = location.coordinate
            let hash = GFUtils.geoHash(forLocation: coordinates)
            
            let documentData: [String: Any] = [
                "geohash": hash,
                "lat": coordinates.latitude,
                "lng": coordinates.longitude
            ]
            
            guard let auxCode = DatabaseManager.shared.user?.joinedRoom else {return}
            let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
            
            roomRef.updateData(documentData){err in
                if let error = err{
                    print(error.localizedDescription)
                }else{
                    self.roomDetails?.geohash = hash
                    self.roomDetails?.lat = coordinates.latitude
                    self.roomDetails?.lng = coordinates.longitude
                    print("location updated successfully")
                }
            }
        }
    }
    
    func fetchNearestLocations(location: CLLocation, completionHandler: @escaping (Result<[NearbyRoomsViewModel],  NetworkError>) -> () ){
        let center = location.coordinate
        
        // Find rooms within 50km
        let radiusInM: Double = 50 * 1000

        // Each item in 'bounds' represents a startAt/endAt pair. We have to issue
        // a separate query for each pair. There can be up to 9 pairs of bounds
        // depending on overlap, but in most cases there are 4.
        let queryBounds = GFUtils.queryBounds(forLocation: center,
                                              withRadius: radiusInM)
//        let queries = queryBounds.map { bound -> Query in
//            guard let bound = any as? GFGeoQueryBounds else { return nil }
        let queries = queryBounds.compactMap { (any) -> Query? in
            guard let bound = any as? GFGeoQueryBounds else { return nil }
            return db.collection(K.FStore.roomsCollection)
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        var matchingDocs = [QueryDocumentSnapshot]()
        
        let dispatchGroup = DispatchGroup()
        
        // Collect all the query results together into a single list
        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
            guard let documents = snapshot?.documents else {
                print("Unable to fetch snapshot data. \(String(describing: error))")
                return
            }
            
            
            for document in documents {
                let lat = document.data()["lat"] as? Double ?? 0
                let lng = document.data()["lng"] as? Double ?? 0
                let coordinates = CLLocation(latitude: lat, longitude: lng)
                let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)

                // We have to filter out a few false positives due to GeoHash accuracy, but
                // most will match
                let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                if distance <= radiusInM {
                    matchingDocs.append(document)
                }
                
            }
            dispatchGroup.leave()
        }

        // After all callbacks have executed, matchingDocs contains the result. Note that this
        // sample does not demonstrate how to wait on all callbacks to complete.
        for query in queries {
            dispatchGroup.enter()
            query.getDocuments(completion: getDocumentsCompletion)
        }
        
        // when loop is done:
        dispatchGroup.notify(queue: .main) {
            self.parseNearbyRoomData(data: matchingDocs, center: location, completed: completionHandler)
        }
    }
    
    private func parseNearbyRoomData(data: [QueryDocumentSnapshot], center: CLLocation , completed: @escaping (Result<[NearbyRoomsViewModel],  NetworkError>) -> ()){
        var updatedData = [NearbyRoomsViewModel]()
        for doc in data{
            let result = Result {
                try doc.data(as: RoomModel.self)
            }
            
            switch result {
            case .success(let room):
                if let room = room {
                    let location = CLLocation(latitude: room.lat ?? 0, longitude: room.lng ?? 0)
                    let distance = location.distance(from: center).magnitude
                    updatedData.append(NearbyRoomsViewModel(name: room.roomName, auxCode: doc.documentID, numberOfUsers: room.users.count, distance: Int(distance)))
//                    completed(.success([]))
                } else {
                    // A nil value was successfully initialized from the DocumentSnapshot,
                    // or the DocumentSnapshot was nil.
                    print("Document does not exist")
                    completed(.failure(.invalidData))
                }
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding room: \(error)")
                completed(.failure(.decodingError))
            }
        }
        completed(.success(updatedData))
    }
    
    // User
    func storeProfileImage(image: UIImage?, completed: @escaping ((URL?) -> ())){
        guard let image = image else { completed(nil);return }
        guard let imageData = image.jpegData(compressionQuality: 1) else { completed(nil); return }
        guard let userUID = Auth.auth().currentUser?.uid else { completed(nil); return }
        let storageRef = storage.reference().child("profilePictures/\(userUID)")
        storageRef.putData(imageData, metadata: nil) { (data, err) in
            guard err == nil else { completed(nil); return }
            storageRef.downloadURL { (url, err) in
                guard let url = url else { completed(nil);return }
                guard err == nil else { completed(nil);return }
                completed(url)
                return
            }
        }
    }
    
    
    //    private func saveAuxCode(user: User, auxCode: String){
    //        let usersRef = self.db.collection(K.FStore.usersCollection).document(user.uid)
    //        usersRef.updateData([K.FStore.auxCodeField:auxCode]) { (err) in
    //            if err != nil {
    //                print(err?.localizedDescription)
    //            }else{
    //                print("saved auxcode")
    //            }
    //        }
    //        // save to userDefaults
    //        UserDefaults.standard.set(auxCode, forKey: K.SpotifyKeys.auxCodeKey)
    //    }
    
    
}
