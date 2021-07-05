//
//  PlaylistViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 8/6/21.
//

import UIKit

class PlaylistTableViewController : UITableViewController{
    var playlistCoverImage:UIImage?{
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    let playlistCoverImageView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SongResultsTableViewCell.self, forCellReuseIdentifier: SongResultsTableViewCell.identifier)
        tableView.register(PlaylistTableHeader.self, forHeaderFooterViewReuseIdentifier: PlaylistTableHeader.identifier)
//        tableView.bounds = view.frame
//        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        let headerView = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250))
                // Image from unsplash: https://unsplash.com/photos/iVPWGCbFwd8
        headerView.imageView.image = UIImage(systemName: "music.note")
        self.tableView.tableHeaderView = headerView
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongResultsTableViewCell.identifier) as! SongResultsTableViewCell
        cell.song = SongDetails(songName: "driver's license", artist: "Olivia Rodrigo", image: "https://i.scdn.co/image/ab67616d0000b273a91c10fe9472d9bd89802e5a", uri: "spotify:track:62vpWI1CHwFy7tMIcSStl8")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlaylistTableHeader.identifier) as! PlaylistTableHeader
        header.playlistCoverImage = self.playlistCoverImage ?? UIImage(systemName: "music.note")
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.frame.height * 0.5
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y
        playlistCoverImageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: y)
    }
}
