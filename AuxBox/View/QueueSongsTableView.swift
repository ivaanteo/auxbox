//
//  QueueSongsTableView.swift
//  AuxBox
//
//  Created by Ivan Teo on 10/6/21.
//

import UIKit

class QueueSongsTableView: NSObject, UITableViewDataSource, UITableViewDelegate{
    
    var tableView: UITableView
    var songData: [SongViewModel]
    weak var viewController: UIViewController?
    var getMoreSongs: (()->())?
    
    @objc func queueButtonTapped(sender: UIButton!) {
        let queueVC = QueueViewController()
        queueVC.modalPresentationStyle = .custom
        queueVC.transitioningDelegate = self
        queueVC.song = songData[sender.tag]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          sender.alpha = 1.0
      }
        viewController?.present(queueVC, animated: true, completion: nil)
    }
    
    @objc func queueButtonTouched(sender: UIButton!){
        sender.alpha = 0.5
    }
    @objc func queueButtonTouchCancel(sender: UIButton!){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          sender.alpha = 1.0
      }
    }
    
    
    init(viewController vc: UIViewController, tableView tv: UITableView, songData data: [SongViewModel]){
        songData = data
        tableView = tv
        viewController = vc
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SongResultsTableViewCell.self, forCellReuseIdentifier: SongResultsTableViewCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongResultsTableViewCell.identifier, for: indexPath) as! SongResultsTableViewCell
        let song = songData[indexPath.row]
        cell.song = song
        cell.queueButton.tag = indexPath.row
        cell.queueButton.addTarget(self, action: #selector(queueButtonTapped), for: .touchUpInside)
        cell.queueButton.addTarget(self, action: #selector(queueButtonTouched), for: .touchDown)
        cell.queueButton.addTarget(self, action: #selector(queueButtonTouchCancel), for: .touchUpOutside)
        cell.contentView.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
extension QueueSongsTableView: UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        QueuePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension QueueSongsTableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard (self.tableView.tableHeaderView != nil) else { return }
        let headerView = self.tableView.tableHeaderView as! StretchyTableHeaderView
        headerView.scrollViewDidScroll(scrollView: scrollView)
        
        let newOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if newOffsetY > contentHeight - scrollView.frame.size.height && newOffsetY > 0 {
            self.getMoreSongs?()
        }
    }
}
