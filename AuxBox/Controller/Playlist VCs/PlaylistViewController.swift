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
//        playlistTableView.frame = .zero
        playlistTableView.allowsSelection = false
        playlistTableView.backgroundColor = UIColor(named: K.Colours.bgColour)
        
        queueSongsTableView = QueueSongsTableView(viewController: self, tableView: playlistTableView, songData: playlistTracks ?? [])
        
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width))
        headerView.imageView.image = playlistCoverImage
        headerView.playlistLabel.text = playlistTitle ?? "-"
        self.queueSongsTableView.tableView.tableHeaderView = headerView
        
        view.addSubview(queueSongsTableView.tableView)
//        queueSongsTableView.tableView.translatesAutoresizingMaskIntoConstraints = false
//        queueSongsTableView.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        queueSongsTableView.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        queueSongsTableView.tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        queueSongsTableView.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        queueSongsTableView.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        navigationController?.navigationBar.backgroundColor = .clear
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.isTranslucent = true
        
//        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
}
