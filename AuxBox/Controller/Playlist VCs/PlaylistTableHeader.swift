//
//  PlaylistTableHeader.swift
//  AuxBox
//
//  Created by Ivan Teo on 8/6/21.
//

import UIKit

class PlaylistTableHeader:UITableViewHeaderFooterView{
    static let identifier = "PlaylistTableHeader"
    
    var playlistCoverImage:UIImage?{
        didSet{
            playlistCoverImageView.image = playlistCoverImage
        }
    }
    
    let playlistCoverImageView = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        playlistCoverImageView.contentMode = .scaleAspectFill
        playlistCoverImageView.clipsToBounds = true
        contentView.addSubview(playlistCoverImageView)
        playlistCoverImageView.translatesAutoresizingMaskIntoConstraints = false
//        playlistCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        playlistCoverImageView.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
        playlistCoverImageView.heightAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
        playlistCoverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        playlistCoverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
