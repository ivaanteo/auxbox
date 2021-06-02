//
//  AuxCodeManager.swift
//  AuxBox
//
//  Created by Ivan Teo on 9/5/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class DatabaseManager{
//    static var connectedToAuxCode:String = ""
//    static var connectedToRoomName:String = ""
    static var roomDetails:Room? = nil
    static var user: UserDetails? = nil
    
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
    static var listener : ListenerRegistration?
    
    func saveUser(user: User, completed: @escaping (String?) -> Void){
        guard let profilePic = user.photoURL else { return }
        guard let displayName = user.displayName else { return }
        guard let email = user.email else { return }
        
        let usersRef = self.db.collection(K.FStore.usersCollection).document(user.uid)
        usersRef.getDocument { (document, error) in
            guard error == nil else { return }
            guard DatabaseManager.user == nil else {
                completed(DatabaseManager.user?.joinedRoom)
                return
            }
            
            if let document = document, document.exists {
                // check if user UID exists
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                print("Document data: \(dataDescription)")
                
                do{
                    let userDetails = try document.data(as: UserDetails.self)
                    DatabaseManager.user = userDetails
                    completed(userDetails?.joinedRoom)
                }catch{
                    completed(nil)
                }
                // if doesn't exist, save to userDefaults
//                if self.retrieveAuxCode() == ""{
//                    UserDefaults.standard.set(document["auxCode"], forKey: K.SpotifyKeys.auxCodeKey)
//                }
                
//                UserDefaults.standard.set(document["auxCode"], forKey: K.SpotifyKeys.auxCodeKey)
                //save to userDefaults
            } else {
                // first timers
                let auxCode = self.getVerifiedAuxCode()
                let userDetails = UserDetails(name: displayName,
                                              email: email,
                                              profilePictureURL: profilePic,
                                              auxCode: auxCode, joinedRoom: nil)
//                usersRef.setData([K.FStore.displayName : displayName,
//                                  K.FStore.profilePic : profilePic.absoluteString,
//                                  K.FStore.email : email,
//                                  K.FStore.auxCodeField : auxCode])
                DatabaseManager.user = userDetails
                do{
                    try usersRef.setData(from: userDetails)
                }catch let error{
                    print(error.localizedDescription)
                    return
                }
                
                // try to throw error
                print("Document does not exist, stored UID")
                // save to userDefaults
                UserDefaults.standard.set(auxCode, forKey: K.SpotifyKeys.auxCodeKey)
            }
            
        }
    }
    
    func addDatabaseListener(auxCode: String, completed: @escaping (Room?) -> Void){
        DatabaseManager.listener = db.collection(K.FStore.roomsCollection).document(auxCode)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    completed(nil)
                    return
                }
                let result = Result {
                    try document.data(as: Room.self)
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
    
    
    
    func getRoomDetails(auxCode:String, completed: @escaping (Result<Room, NetworkError>) -> Void){
        db.collection(K.FStore.roomsCollection).document(auxCode).getDocument { (document, err) in
            let result = Result {
                try document?.data(as: Room.self)
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
                    DatabaseManager.user?.joinedRoom = auxCode
                    DatabaseManager.roomDetails = room
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
        
        DatabaseManager.user?.joinedRoom = auxCode
        usersRef.updateData(["joinedRoom": auxCode]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("updateUserRoom successfully updated")
            }
        }
    }
    
    func updateRoomToQueue(uri: String, completed: @escaping (String)->Void ){
        guard let auxCode = DatabaseManager.user?.joinedRoom else {return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        roomRef.updateData(["toQueue" : FieldValue.arrayUnion([uri])]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                completed(err.localizedDescription)
            } else {
                completed(K.Texts.queuedSongText)
            }
        }
    }
    
    func updateEntireRoom(room: Room){
        guard let auxCode = DatabaseManager.user?.auxCode else { return }
        do{
            try db.collection(K.FStore.roomsCollection).document(auxCode).setData(from: room)
        }catch let error{
            print(error.localizedDescription)
            return
        }
    }
    
    func updateRoomUsers(auxCode:String, create: Bool){
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        if create{
            roomRef.updateData(["users" : FieldValue.arrayUnion([userUID])])
        }else{
            roomRef.updateData(["users" : FieldValue.arrayRemove([userUID])])
        }
    }
    
    func didQueueSongs(queueList : [String]){
        guard let auxCode = DatabaseManager.user?.auxCode else {return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        guard let currentQueue = DatabaseManager.roomDetails?.currentQueue else { return }
        var updatedCurrentQueue = currentQueue
        for uri in queueList{
            updatedCurrentQueue.append(uri)
        }
        roomRef.updateData(["currentQueue" : updatedCurrentQueue, "toQueue" : FieldValue.arrayRemove(queueList)])
//        roomRef.updateData(["toQueue" : FieldValue.arrayRemove(queueList)])
    }
    
    func updateRoomCurrentQueue(songURIToRemove: String){
        guard let auxCode = DatabaseManager.user?.auxCode else {return}
        let roomRef = self.db.collection(K.FStore.roomsCollection).document(auxCode)
        roomRef.updateData(["currentQueue" : FieldValue.arrayRemove([songURIToRemove])])
    }
    
    func updateRoomNowPlaying(nowPlaying: SongDetails){
        guard let auxCode = DatabaseManager.user?.auxCode else { return }
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
//                do{
//                    try roomRef.setData(from: nowPlaying, merge: true)
//
//                }catch let error{
//                    print(error.localizedDescription)
//                }
    }
    
    func startActiveRoom(room: Room){
        // don't need to check that room exists since you're setting data, not creating another collection
        guard let auxCode = DatabaseManager.user?.auxCode else { return }
        do{
            try db.collection(K.FStore.roomsCollection).document(auxCode).setData(from: room)
        }catch let error{
            print(error.localizedDescription)
            return
        }
        print("did update active room")
        DatabaseManager.roomDetails = room
    }
    
    func deleteActiveRoom(){
        guard let auxCode = DatabaseManager.user?.auxCode else { return }
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
        DatabaseManager.roomDetails = nil
        DatabaseManager.user?.joinedRoom = nil
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
                // save here
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
