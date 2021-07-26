//
//  NowPlayingViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 27/4/21.
//

import UIKit

class NowPlayingViewController: UIViewController {
    let songImage = UIImageView()
    let songArtistLabel = UILabel()
    let songNameLabel = UILabel()
    let songStackView = UIStackView()
    let roomNameLabel = UILabel()
    let mainStackView = UIStackView()
    var scrollView = UIScrollView()
    
    let tableView = SelfSizingTableView()
    
    var roomName: String?{
        didSet{
            roomNameLabel.text = roomName
            
        }
    }
    
    var currentQueue = [String]()
//    var currentQueueData = [SongDetails]()
    var normalQueue = [String]()
    
    
    var songImgLength: Double?{
        Double(view.frame.width*0.7)
    }
    var edgePadding: Double?{
        Double(view.frame.width*0.15)
    }
    var labelYAnchor:CGFloat{
        // (entire height - 3 padding - length of img) / 2 + 2 padding
        // height = 1.5 width bc i set that in previous controller
        -0.475 * view.frame.width
    }
    
    fileprivate func setupSongImageConstraints() {
        // use constraints instead of frame because it works.
        songImage.translatesAutoresizingMaskIntoConstraints = false
        songImage.widthAnchor.constraint(equalToConstant: CGFloat(songImgLength!)).isActive = true
        songImage.heightAnchor.constraint(equalToConstant: CGFloat(songImgLength!)).isActive = true
//        songImage.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(edgePadding!)).isActive = true
//        songImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        songImage.contentMode = .scaleAspectFit
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let backgroundLayer = Colors().gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
        songImage.setupShadow(heightInput: 5.5)
        songImage.tintColor = .white
        setupSongImageConstraints()
        setupLabels()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CurrentQueueCell.self, forCellReuseIdentifier: "currentQueueCell")
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        
        
        
//        scrollView.backgroundColor = .green
        view.addSubview(scrollView)
        
//        songNameLabel.setupLabel(displayText: "", fontSize: 24, overrideText: false)
//        songArtistLabel.setupLabel(displayText: "", fontSize: 18, overrideText: false)
//        roomNameLabel.setupLabel(displayText: "", fontSize: 16, overrideText: false)
//        setupText(songTitle, fontSize: 24)
//        setupText(songArtist, fontSize: 18)
        

        
        
        setupStackView(songStackView, spacing: 5, alignment: .leading)
        setupStackView(mainStackView, spacing: 25, alignment: .center)
        
        songStackView.addArrangedSubview(songNameLabel)
        songStackView.addArrangedSubview(songArtistLabel)
        
        mainStackView.addArrangedSubview(roomNameLabel)
        mainStackView.addArrangedSubview(songImage)
        mainStackView.addArrangedSubview(songStackView)
        
//        mainStackView.addArrangedSubview(tableView)
        
//        view.addSubview(songImage)
        
//        view.addSubview(songStackView)
//        setupStackViewConstraints(songStackView)
        
//        mainStackView.frame = CGRect(x: Double(view.frame.width)/2, y: edgePadding!, width: songImgLength!, height: 100)
//        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 20)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        scrollView.contentSize = CGSize(width: view.frame.width, height: 2000)
//        scrollView.contentSize = .zero

        scrollView.addSubview(mainStackView)
        scrollView.addSubview(tableView)
        setupStackViewConstraints(mainStackView)
        
        tableView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 40).isActive = true
        tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 35).isActive = true
        tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        
        
        updateUI()
    }
    
    fileprivate func setupLabels(){
        songNameLabel.setupLabel(displayText: "", fontSize: 24, overrideText: false)
        songArtistLabel.setupLabel(displayText: "", fontSize: 18, overrideText: false)
        roomNameLabel.setupLabel(displayText: "", fontSize: 16, overrideText: false)
        songNameLabel.translatesAutoresizingMaskIntoConstraints = false
        songArtistLabel.translatesAutoresizingMaskIntoConstraints = false
        roomNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        roomNameLabel.textAlignment = .center
        
        roomNameLabel.widthAnchor.constraint(equalToConstant: CGFloat(songImgLength!)).isActive=true
        songNameLabel.widthAnchor.constraint(equalToConstant: CGFloat(songImgLength!)).isActive=true
        songArtistLabel.widthAnchor.constraint(equalToConstant: CGFloat(songImgLength!)).isActive=true
    }
    
    func updateUI(){
        DispatchQueue.main.async {
            self.songNameLabel.text = DatabaseManager.shared.roomDetails?.nowPlaying.songName ?? "Nothing's Playing"
            self.songArtistLabel.text = DatabaseManager.shared.roomDetails?.nowPlaying.artist ?? "-"
            self.roomNameLabel.text = DatabaseManager.shared.roomDetails?.roomName ?? "Unplugged"
        }
        SpotifyAuthManager.shared.downloadImage(from: DatabaseManager.shared.roomDetails?.nowPlaying.image ?? "") { (image) in
            DispatchQueue.main.async {
                self.songImage.image = image
            }
        }
//        if let imgURL = DatabaseManager.roomDetails?.nowPlaying.image{
////            if let url = URL(string: imgURL){
////                if let data = try? Data(contentsOf: url){
////                    DispatchQueue.main.async {
////                        self.songImage.image = UIImage(data:data)
////                    }
////                }
////            }
//            SpotifyAuthManager.shared.downloadImage(from: imgURL) { (image) in
//                DispatchQueue.main.async {
//                    self.songImage.image = image
//                }
//            }
//        }
//        else{
//            DispatchQueue.main.async {
//                self.songImage.image = UIImage(systemName: "music.mic")
//            }
//        }
        currentQueue = DatabaseManager.shared.roomDetails?.currentQueue ?? []
        normalQueue = DatabaseManager.shared.roomDetails?.normalQueue ?? []
//        if currentQueue != []{
//            for uri in currentQueue!{
//                SpotifyAuthManager.shared.getSongDetails(trackURI: uri) { res in
//                    switch res{
//                    case .success(let data):
//                        self.currentQueueData.append(data)
//                    case .failure:
//                        print("error fetching songData")
//                    }
//                }
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }else{
//            currentQueueData = []
//        }
        
        // filter first
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("reloaded data")
        }
    }
    
    fileprivate func displayAlert(text: String, delay: Double){
        let alert = UIAlertController(title: text, message: "", preferredStyle: .alert)
        if text != K.Texts.queuedSongText{
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }else{
            present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
                self.dismiss(animated: true) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    fileprivate func setupStackView(_ stackView: UIStackView, spacing: Int, alignment: UIStackView.Alignment) {
        stackView.axis  = .vertical
        stackView.distribution  = .equalSpacing
        stackView.alignment = alignment
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = CGFloat(spacing)
//        stackView.setCustomSpacing(5, after: songTitle)
    }
    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
        // we enable top anchor only so that we don't fix the HEIGHT of the stackview
        // otherwise it will force the 2 item stack view to fill up the space
        // thus one item on top, the other at the bottom
//        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 35).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        
        
//        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor,
//                                            constant: CGFloat(-edgePadding!)).isActive = true
//        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(edgePadding!)).isActive = true
    }
    
//    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
//        // we enable top anchor only so that we don't fix the HEIGHT of the stackview
//        // otherwise it will force the 2 item stack view to fill up the space
//        // thus one item on top, the other at the bottom
//        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
//                                            constant: CGFloat(-edgePadding!)).isActive = true
////        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
////                                           constant: CGFloat(edgePadding!)).isActive = true
//    }
}

extension NowPlayingViewController:UITableViewDelegate{
    
}

extension NowPlayingViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? currentQueue.count : normalQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let queueList = indexPath.section == 0 ? currentQueue : normalQueue
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentQueueCell", for: indexPath) as! CurrentQueueCell
//        let uri = currentQueue[indexPath.row]
        let uri = queueList[indexPath.row]
        SpotifyAuthManager.shared.getSongDetails(trackURI: uri) { res in
            switch res{
            case .success(let song):
                cell.song = song
            case .failure:
                cell.song = SongViewModel(songName: "", artist: "", image: "", uri: "")
            }
        }
        
//        let song = currentQueueData[indexPath.row]
//        cell.song = song
        cell.contentView.isUserInteractionEnabled = false
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let text = UILabel()
        var queueText: String{
            if section == 0{
                if currentQueue.count > 1{
                    return "\(currentQueue.count) songs in premium queue"
                }else if currentQueue.count == 1{
                    return "\(currentQueue.count) song in premium queue"
                }
                return "No songs in premium queue"
            }
            else if section == 1{
                if normalQueue.count > 1{
                    return "\(normalQueue.count) songs in queue"
                }else if normalQueue.count == 1{
                    return "\(normalQueue.count) song in queue"
                }
                return "No songs in queue"
            }
            return "Oops, something went wrong!"
        }
        
        text.setupLabel(displayText: queueText, fontSize: 18)
        text.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(text)
        header.heightAnchor.constraint(equalToConstant: 50).isActive = true
        text.heightAnchor.constraint(equalToConstant: 65).isActive = true
        text.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 30).isActive = true

        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

class SelfSizingTableView: UITableView {
    var minHeight : CGFloat = 450

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = max(minHeight, contentSize.height + 50)
        return CGSize(width: contentSize.width, height: height)
    }
}


