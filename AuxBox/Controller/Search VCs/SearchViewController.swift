//
//  SearchViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 9/7/21.
//

import UIKit
import SafariServices
import WebKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    let spotifySearchManager = SpotifySearchManager()
    let searchBar = UISearchBar()
    var playlistCollectionView: UICollectionView!
    //    var playlistData = [PlaylistViewModel(name: "Vibe", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA"),
    //                        PlaylistViewModel(name: "Yea", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA"),
    //                        PlaylistViewModel(name: "Softly", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA"),
    //                        PlaylistViewModel(name: "Softly", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA"),
    //                        PlaylistViewModel(name: "Softly", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA"),
    //                        PlaylistViewModel(name: "Softly", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA"),
    //                        PlaylistViewModel(name: "Softly", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA"),
    //                        PlaylistViewModel(name: "Softly", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA"),
    //                        PlaylistViewModel(name: "Softly", imgURL: "https://i.scdn.co/image/ab67706f0000000373f5d3378cc482524b1cfbbf", playlistID: "37i9dQZF1DX8OCw6EqwHPA")]
    var playlistData = [PlaylistViewModel]()
    var isFetchingPlaylist = false
    var pageNumber = 1
    var loadedAllPlaylists = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
        navigationItem.backButtonTitle = ""
        setupSearchBar()
        searchController.delegate = self
        setupCollectionView()
        fetchMorePlaylists()
    }
    
    fileprivate func fetchMorePlaylists() {
        if PersistenceManager.retrieveRefreshToken() == ""{
            // not authorized yet
            // show connect button
            print("not authorized")
        }else{
            // make sure not already fetching
            guard !isFetchingPlaylist else { print("still fetching");return }
            guard !loadedAllPlaylists else { print("ended"); return}
            self.isFetchingPlaylist = true
            DispatchQueue.main.async {
                self.playlistCollectionView.reloadData()
            }
//            self.playlistCollectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: 0) as! PlaylistFooterView.
            
//            let footer = self.playlistCollectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: )
//            visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter)[0] as! PlaylistFooterView
//            footer.startSpinning()
            
            // fetch data
            SpotifyAuthManager.shared.getUserPlaylists(pageNumber: pageNumber) { (res) in
                self.isFetchingPlaylist = false
                switch res{
                case .success(let playlists):
                    if playlists.count < 20{
                        // prevent call after loading all existing playlist
                        self.loadedAllPlaylists = true
                    }
                    DispatchQueue.main.async {
                        self.playlistData.append(contentsOf: playlists)
                        self.playlistCollectionView.reloadData()
                        self.pageNumber += 1
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    @objc func connectSpotifyTapped(sender: UIButton!) {
        guard let url = URL(string: "\(SpotifyAPI.accountURL)authorize?client_id=\(SpotifyAPI.clientID)&response_type=code&redirect_uri=\(SpotifyAPI.redirectURI)&scope=\(HeaderField.scope)") else {
            print("error, failed to authorize spotify")
            return
        }
//        presentSafarisVC(with: url)
        
        let vc = WebKitViewController(url: url, title: "Connect to Spotify", authorizeUser: authorizeFirstTimeUser)
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    fileprivate func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        let size = CGSize(width:(view.frame.width - 60)/2, height: (view.frame.width+60)/2)
        layout.itemSize = size
        playlistCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        playlistCollectionView.delegate = self
        playlistCollectionView.dataSource = self
        playlistCollectionView.setupPlaylistCollectionView()
        playlistCollectionView.register(PlaylistFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PlaylistFooterView.footerId)
        playlistCollectionView.register(PlaylistHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderView.headerId)
//        playlistCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(playlistCollectionView)
        playlistCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playlistCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        playlistCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        playlistCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    fileprivate func setupSearchBar(){
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.placeholder = "What's next, DJ?"
        navigationItem.searchController?.searchBar.searchTextField.font = UIFont(name: "Futura", size: 12)
        navigationItem.searchController?.searchBar.searchTextField.textColor = UIColor(named: K.Colours.textColour)
        navigationItem.searchController?.searchBar.searchTextField.leftView?.tintColor = UIColor(named: K.Colours.textColour)
        navigationItem.searchController?.searchBar.searchTextField.backgroundColor = .white
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc func performSearch(_ vc: SearchResultsViewController) {
        guard let searchText = searchController.searchBar.text else {return}
        if searchText != ""{
            //            requestToken = spotifySearchManager.retrieveSearchResults(query: searchText, type: "track", token: PersistenceManager.retrieveClientAccessToken()) { result in
            spotifySearchManager.retrieveSearchResults(query: searchText, type: "track", token: PersistenceManager.retrieveClientAccessToken()) { result in
                switch result {
                case .success(let songData):
                    vc.songData = songData
                    // check if songData is empty
                    // if it is, show an empty view telling them about the error
                    if (songData.isEmpty){
                        DispatchQueue.main.async {
                            vc.errorLabel = UILabel()
                            vc.errorLabel!.text = "Oops, we couldn't find anything matching '\(searchText)'!"
                            vc.tableView.backgroundView = vc.errorLabel
                            vc.tableView.separatorStyle = .none
                            vc.hideActivityIndicator()
                            vc.tableView.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async {
                            vc.tableView.backgroundView = .none
                            vc.tableView.separatorStyle = .singleLine
                            vc.hideActivityIndicator()
                            vc.tableView.reloadData()
                        }
                    }
                case .failure(URLError.cancelled):
                    // Request was cancelled, no need to do any handling
                    break
                case .failure(let error):
                    // show them empty screen with error message, eg. no internet connection
                    vc.songData = []
                    DispatchQueue.main.async {
                        vc.errorLabel = UILabel()
                        vc.errorLabel!.text = "Sorry, something went wrong! \(error.localizedDescription)"
                        vc.tableView.backgroundView = vc.errorLabel
                        vc.tableView.separatorStyle = .none
                        vc.hideActivityIndicator()
                        vc.tableView.reloadData()
                    }
                }
            }
        }else{
            vc.songData = []
            DispatchQueue.main.async{
                vc.hideActivityIndicator()
                vc.tableView.reloadData()
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let vc = searchController.searchResultsController as? SearchResultsViewController else {return}
        vc.showActivityIndicator()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: vc)
        perform(#selector(self.performSearch), with: vc, afterDelay: 0.5)
    }
    func didPresentSearchController(_ searchController: UISearchController) {
        // retrieve access token from user defaults and use it
        SpotifyAuthManager.shared.getClientAccessToken(completed: nil)
    }
    
    private func presentSafariVC(with url: URL){
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor  = UIColor(named: K.Colours.orange)
        safariVC.preferredBarTintColor      = .white
        safariVC.delegate                   = self
        safariVC.modalPresentationStyle = .automatic
        present(safariVC, animated: true)
    }
    
    func authorizeFirstTimeUser(with authCode: String){
        // if can't get request token --> auth user
        print("auth first time user")
        SpotifyAuthManager.shared.completeAuthorizeRequest(with: authCode) { results in
            guard let accessToken = results else {
                print("failed to authorize")
                return
            }
            DispatchQueue.main.async {
                //update ui
                print(accessToken, "got the first time user access token")
                self.dismiss(animated: true, completion: nil)
            }
            self.fetchMorePlaylists()
        }
    }
}

extension SearchViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlistViewController = PlaylistViewController()
        SpotifyAuthManager.shared.downloadImage(from: playlistData[indexPath.row].imgURL ?? "") { (image) in
            playlistViewController.playlistCoverImage = image
            playlistViewController.playlistTitle = self.playlistData[indexPath.row].name
            playlistViewController.playlistID = self.playlistData[indexPath.row].playlistID
        }
        SpotifyAuthManager.shared.getPlaylistDetails(playlistID: playlistData[indexPath.row].playlistID, market: "SG") { (res) in
            switch res{
            case .success(let songDetails):
                playlistViewController.playlistTracks = songDetails
                DispatchQueue.main.async {
                    playlistViewController.playlistTableView.reloadData()
                }
            case .failure(let err):
                //                self.presentAlert(title: "Error", message: failure.localizedDescription)
                self.showAlert(title: "Error", message: err.localizedDescription)
                return
            }
        }
        self.navigationController?.pushViewController(playlistViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            fetchMorePlaylists()
        }
    }
    
    // footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderView.headerId, for: indexPath) as! PlaylistHeaderView
            header.connectSpotifyButton.isHidden = PersistenceManager.retrieveRefreshToken() != ""
            header.connectSpotifyButton.addTarget(self, action: #selector(connectSpotifyTapped), for: .touchUpInside)
            // add target
            return header
        }
        
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PlaylistFooterView.footerId, for: indexPath) as! PlaylistFooterView
        if isFetchingPlaylist{
            footer.startSpinning()
        }else{
            footer.stopSpinning()
        }
        return footer
    }
}

extension SearchViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return section == 0 ? self.playlistData.count : 1
        return self.playlistData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        //        cell.playlist = Playlist(name: "Chill Hits", imageURL: "https://i.scdn.co/image/ab67706f00000003cf8e264c6a92e245402ecb7a")
        guard let imgURL = playlistData[indexPath.row].imgURL else { return cell}
        let representedIdentifier = playlistData[indexPath.row].playlistID
        cell.representedIdentifier = representedIdentifier
        SpotifyAuthManager.shared.downloadImage(from: imgURL) { (image) in
            DispatchQueue.main.async {
                if cell.representedIdentifier == representedIdentifier{
                    cell.playlistImageView.image = image ?? UIImage(systemName: "music.note")
                    cell.playlistTitleLabel.text = self.playlistData[indexPath.row].name
                }
            }
        }
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout{
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return PersistenceManager.retrieveRefreshToken() == "" ?  CGSize(width: view.frame.width, height: 130) : CGSize(width: view.frame.width, height: 50)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}

extension SearchViewController:SFSafariViewControllerDelegate{
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        let currentURL = URL.absoluteString
        if currentURL.contains("\(SpotifyAPI.redirectURL)?code="){
            // check if theres a refresh token
            if PersistenceManager.retrieveRefreshToken() == "" {
                // no refresh token, first time opening app
                // means you gotta get an ACCESS TOKEN, rather than a new refresh token
                let endpoint = String(currentURL.split(separator: "=")[1])
                self.authorizeFirstTimeUser(with: endpoint)
            } else {
                // there's a refresh token saved in userdefaults
                // getRefreshToken will save it as well
                SpotifyAuthManager.shared.getRefreshToken() { results in
                    // results means the completion handler "completed"
                    guard let refreshToken = results else {
                        print("failed to get refresh token")
                        return
                    }
                    print("access token: ", PersistenceManager.retrieveAccessToken())
                    print("refresh token: ", refreshToken)
                    // cache this token here
                    // dismiss safari when done
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
}
