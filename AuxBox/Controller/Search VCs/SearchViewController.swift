//
//  SearchViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 9/7/21.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    let spotifySearchManager = SpotifySearchManager()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        searchController.delegate = self
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
}
