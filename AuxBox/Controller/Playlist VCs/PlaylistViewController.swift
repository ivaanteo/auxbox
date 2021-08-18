//
//  PlaylistViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 8/6/21.
//

import UIKit

class PlaylistViewController : UIViewController{
    var playlistID:String?
    var playlistCoverImage:UIImage?{
        didSet{
            DispatchQueue.main.async {
                self.playlistTableView.reloadData()
            }
        }
    }
    var playlistTracks : [SongViewModel]?{
        didSet{
            DispatchQueue.main.async {
                self.queueSongsTableView.songData = self.playlistTracks!
                self.queueSongsTableView.tableView.reloadData()
            }
        }
    }
    let playlistTableView = UITableView()
    var playlistTitle:String?
    var queueSongsTableView: QueueSongsTableView!
    var pageNumber = 0
    
    var isFetchingSongs = false
    var loadedAllSongs = false
    
    var footerView: LoadingFooterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistTableView.frame = view.bounds
        playlistTableView.allowsSelection = false
        playlistTableView.backgroundColor = UIColor(named: K.Colours.bgColour)
        
        queueSongsTableView = QueueSongsTableView(viewController: self, tableView: playlistTableView, songData: playlistTracks ?? [])
        queueSongsTableView.getMoreSongs = loadMoreSongs
        
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width))
        headerView.imageView.image = playlistCoverImage
        headerView.playlistLabel.text = playlistTitle ?? "-"
        self.queueSongsTableView.tableView.tableHeaderView = headerView
        
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80))
        self.queueSongsTableView.tableView.tableFooterView = footerView
        view.addSubview(queueSongsTableView.tableView)
        
        queueSongsTableView.tableView.reloadData()
    }
    
    func loadMoreSongs(){
        guard !isFetchingSongs else { return }
        guard !loadedAllSongs else { return }
        
        DispatchQueue.main.async {
            self.footerView?.startSpinning()
            self.queueSongsTableView.tableView.reloadData()
        }
        self.isFetchingSongs = true
        SpotifyAuthManager.shared.getPlaylistDetails(playlistID: self.playlistID!, market: "SG", pageNumber: self.pageNumber) { (res) in
            switch res{
            case .success(let songDetails):
                self.playlistTracks?.append(contentsOf: songDetails)
                self.pageNumber += 1
                
                // upon reaching end
                if songDetails.count == 0{
                    self.loadedAllSongs = true
                    // remove footer
                    DispatchQueue.main.async {
                        self.queueSongsTableView.tableView.tableFooterView = UIView(frame: .zero)
                        self.queueSongsTableView.tableView.reloadData()
                    }
                }
            case .failure(let failure):
                self.showAlert(title: "Error", message: failure.localizedDescription)
                return
            }
            self.isFetchingSongs = false
            DispatchQueue.main.async {
                self.footerView?.stopSpinning()
                self.queueSongsTableView.tableView.reloadData()
            }
        }
    }
    
}
