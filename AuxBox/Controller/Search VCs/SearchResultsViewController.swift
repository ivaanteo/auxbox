//
//  SearchResultsViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 29/4/21.
//

import UIKit

class SearchResultsViewController:UIViewController{
    var tableCount:Int?
//    var songData:SongData?
    var songData = [SongDetails]()
    var activityView = UIActivityIndicatorView(style: .large)
    var activityViewIsShown: Bool = false
    var errorLabel: UILabel?{
        didSet{
            errorLabel!.textColor = UIColor.white
            errorLabel!.textAlignment = .center
            errorLabel!.font = UIFont(name: "Futura", size: 24)
            errorLabel!.backgroundColor = UIColor(named: K.Colours.bgColour)
            errorLabel!.adjustsFontSizeToFitWidth = true
            errorLabel!.minimumScaleFactor = 0.75
            errorLabel!.numberOfLines = 2
        }
    }
    
    @objc func queueButtonTapped(sender: UIButton!) {
        let queueVC = QueueViewController()
        queueVC.modalPresentationStyle = .custom
        queueVC.transitioningDelegate = self
        queueVC.song = songData[sender.tag]
        self.present(queueVC, animated: true, completion: nil)
    }
    
    func showActivityIndicator() {
        if !activityViewIsShown{
            DispatchQueue.main.async {
                self.activityView.startAnimating()
            }
        }
    }

    func hideActivityIndicator(){
        if (activityView.isAnimating){
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
            }
        }
    }
    
    let tableView = UITableView()
    override func viewDidLayoutSubviews() {
        view.backgroundColor = UIColor(named: K.Colours.bgColour)
        tableView.frame = view.frame
        tableView.backgroundColor = UIColor(named: K.Colours.bgColour)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SongResultsTableViewCell.self, forCellReuseIdentifier: "songResultsCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDrag
        view.addSubview(tableView)
        
        self.activityView.center = self.view.center
        self.activityView.hidesWhenStopped = true
        self.activityView.color = .white
        
        view.addSubview(activityView)
        view.bringSubviewToFront(activityView)
    }
    
    
}

extension SearchResultsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
}

extension SearchResultsViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songResultsCell", for: indexPath) as! SongResultsTableViewCell
        
        let song = songData[indexPath.row]
        cell.song = song
        cell.queueButton.tag = indexPath.row
        cell.queueButton.addTarget(self, action: #selector(queueButtonTapped), for: .touchUpInside)
        cell.contentView.isUserInteractionEnabled = false
        return cell
    }
    // HEIGHT
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    // Add loading view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let rows = songData.count else {
//            return 0
//        }
        return songData.count
    }
}

extension SearchResultsViewController:UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        QueuePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
