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
    var playlistTracks : [SongDetails]?{
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlistTableView.frame = view.bounds
        playlistTableView.allowsSelection = false
        playlistTableView.backgroundColor = UIColor(named: K.Colours.bgColour)
        
        queueSongsTableView = QueueSongsTableView(viewController: self, tableView: playlistTableView, songData: playlistTracks ?? [])
        
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 300))
        headerView.imageView.image = playlistCoverImage
        headerView.playlistLabel.text = playlistTitle ?? "-"
        self.queueSongsTableView.tableView.tableHeaderView = headerView
        
        view.addSubview(queueSongsTableView.tableView)
        queueSongsTableView.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.navigationBar.backgroundColor = .none
    }
    
    
}
