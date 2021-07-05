//
//  QueueViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 30/4/21.
//

import UIKit
class QueueViewController: UIViewController{
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var song:SongDetails?{
        didSet{
            if let imgURL = song?.image{
//                if let url = URL(string: imgURL){
//                    if let data = try? Data(contentsOf: url){
//                        songImage.image = UIImage(data:data)
//                    }
//                }
                SpotifyAuthManager.shared.downloadImage(from: imgURL) { (image) in
                    DispatchQueue.main.async {
                        self.songImage.image = image
                    }
                }
            }
            // bolds text
            songTitle.attributedText = NSAttributedString(string: song!.songName, attributes: [.strokeWidth: -1])
            songArtist.text = song?.artist
        }
    }
    let songImage = UIImageView()
    let songTitle = UILabel()
    let songArtist = UILabel()
    let stackView = UIStackView()
    let queueButton = UIButton()
    
    
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
    @objc func queueButtonTapped(sender: UIButton!){
        guard let auxCode = DatabaseManager.shared.user?.joinedRoom else {displayAlert(text: "Please connect to a room first!", delay: 1); return}
        if auxCode != ""{
            guard let uri = song?.uri else {return}
            DatabaseManager.shared.updateRoomToQueue(uri: uri){text in
                self.displayAlert(text: text, delay: 1)
            }
        }else{
            displayAlert(text: "Please connect to a room first!", delay: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let backgroundLayer = Colors().gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        
        setupText(songTitle, fontSize: 24)
        setupText(songArtist, fontSize: 18)
//        setupQueueButton(queueButton)
        queueButton.setupTransparentButton(btnTitle: "Queue Now", bgAlpha: 0.5, fontSize: 16, width: CGFloat(songImgLength!), height: CGFloat(edgePadding!))
        
        view.addSubview(songImage)
        view.addSubview(queueButton)
        setupButtonConstraints()
        
        songTitle.translatesAutoresizingMaskIntoConstraints = false
        songArtist.translatesAutoresizingMaskIntoConstraints = false
        songImage.translatesAutoresizingMaskIntoConstraints = false
        // use constraints instead of frame because it works.
        
        songImage.widthAnchor.constraint(equalToConstant: CGFloat(songImgLength!)).isActive = true
        songImage.heightAnchor.constraint(equalToConstant: CGFloat(songImgLength!)).isActive = true
        songImage.topAnchor.constraint(equalTo: view.topAnchor,
                                       constant: CGFloat(edgePadding!)).isActive = true
        songImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        songImage.contentMode = .scaleAspectFit
//        songImage.clipsToBounds = true
        songImage.setupShadow()
        
        setupStackView(stackView, songTitle, songArtist)
        view.addSubview(stackView)
        setupStackViewConstraints(stackView)
    }
    
    override func viewDidLayoutSubviews() {
            if !hasSetPointOrigin {
                hasSetPointOrigin = true
                pointOrigin = self.view.frame.origin
            }
        }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
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
    
    fileprivate func setupStackView(_ stackView: UIStackView, _ songTitle: UILabel, _ songArtist: UILabel) {
        stackView.axis  = .vertical
        stackView.distribution  = .equalCentering
        stackView.alignment = .leading
        stackView.addArrangedSubview(songTitle)
        stackView.addArrangedSubview(songArtist)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(5, after: songTitle)
    }
    fileprivate func setupStackViewConstraints(_ stackView: UIStackView) {
        // we enable top anchor only so that we don't fix the HEIGHT of the stackview
        // otherwise it will force the 2 item stack view to fill up the space
        // thus one item on top, the other at the bottom
        stackView.centerYAnchor.constraint(equalTo: view.bottomAnchor,
                                           constant: labelYAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                            constant: CGFloat(-edgePadding!)).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: CGFloat(edgePadding!)).isActive = true
    }
    fileprivate func setupText(_ text: UILabel, fontSize: CGFloat) {
//        text.cen
        text.textColor = UIColor.white
        text.font = UIFont(name: "Futura", size: fontSize)
        text.backgroundColor = UIColor.white.withAlphaComponent(0)
//        text.backgroundColor = .black
        text.adjustsFontSizeToFitWidth = true
        text.minimumScaleFactor = 0.75
        text.numberOfLines = 2
//        text.isScrollEnabled = false
//        text.textContainer.lineBreakMode = .byWordWrapping
    }
    
    fileprivate func setupButtonConstraints() {
        queueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                            constant: CGFloat(-1 * edgePadding!)).isActive = true
        queueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        queueButton.addTarget(self, action: #selector(queueButtonTapped), for: .touchUpInside)
    }
}
