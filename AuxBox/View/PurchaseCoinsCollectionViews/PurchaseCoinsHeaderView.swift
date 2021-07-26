//
//  PurchaseCoinsHeaderView.swift
//  AuxBox
//
//  Created by Ivan Teo on 13/7/21.
//

import UIKit

class PurchaseCoinsHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()
    static let headerId = "purchaseCoinHeader"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .none
        setupViews()
    }
    
    func setupViews(){
        titleLabel.setupLabel(displayText: "Purchase AuxCoins", fontSize: 28)
        subtitleLabel.setupLabel(displayText: "Unleash your inner DJ with great music, and, of course, AuxCoins!", fontSize: 16)
        setupStackView()
    }
    func setupStackView(){
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing = 20
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
//        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10).isActive = true
//        stackView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
//        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
}
