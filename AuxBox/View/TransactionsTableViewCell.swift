//
//  TransactionsTableViewCell.swift
//  AuxBox
//
//  Created by Ivan Teo on 8/7/21.
//

import UIKit

class TransactionsTableViewCell:UITableViewCell{
    static let cellId = "txnCell"
    var viewModel: TransactionViewModel?{
        didSet{
            DispatchQueue.main.async {
                self.dateLabel.text = self.viewModel!.date
                self.songNameLabel.text = self.viewModel!.songName
                self.artistLabel.text = self.viewModel!.artist
            }
        }
    }
    
    var asHost: Bool?{
        didSet{
            DispatchQueue.main.async {
                self.txnValueLabel.text = self.asHost! ? "+1" : "-1"
                
            }
        }
    }
    
    let dateLabel = UILabel()
    let songNameLabel = UILabel()
    let artistLabel = UILabel()
    let stackView = UIStackView()
    
    let txnValueLabel = UILabel()
    let coinImageView = UIImageView()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        dateLabel.setupLabel(displayText: "", fontSize: 12, overrideText: false)
        songNameLabel.setupLabel(displayText: "", fontSize: 16, minScaleFactor: 1 ,minLines: 1, overrideText: false)
        artistLabel.setupLabel(displayText: "", fontSize: 14, overrideText: false)
        songNameLabel.translatesAutoresizingMaskIntoConstraints = false
        songNameLabel.widthAnchor.constraint(equalToConstant: frame.width * 0.8).isActive = true
        layoutTransactionValue()
        setupStackView()
        
        
        
        
        
    }
    
    fileprivate func layoutTransactionValue(){
        txnValueLabel.setupLabel(displayText: "", fontSize: 14, overrideText: false)
        coinImageView.image = UIImage(systemName: "star.circle.fill")
        coinImageView.tintColor = UIColor(named: K.Colours.orange)
        txnValueLabel.translatesAutoresizingMaskIntoConstraints = false
        coinImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(txnValueLabel)
        contentView.addSubview(coinImageView)
        
        
        txnValueLabel.trailingAnchor.constraint(equalTo: coinImageView.leadingAnchor, constant: -5).isActive = true
        txnValueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        coinImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        coinImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    fileprivate func setupStackView(){
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(songNameLabel)
        stackView.addArrangedSubview(artistLabel)
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
