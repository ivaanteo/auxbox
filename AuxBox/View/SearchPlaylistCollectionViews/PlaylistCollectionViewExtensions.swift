//
//  PlaylistCollectionViewExtensions.swift
//  AuxBox
//
//  Created by Ivan Teo on 12/7/21.
//

import UIKit

extension UICollectionView{
    func setupPlaylistCollectionView(){
        self.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
//        self.register(NowPlayingCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "nowPlayingCollectionReusableView")
        self.backgroundColor = .none
        self.translatesAutoresizingMaskIntoConstraints = false
        self.showsVerticalScrollIndicator = false
    }
}
