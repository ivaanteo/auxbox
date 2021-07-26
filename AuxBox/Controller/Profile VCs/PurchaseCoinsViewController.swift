//
//  PurchaseCoinsViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 13/7/21.
//

import UIKit
import StoreKit

class PurchaseCoinsCollectionViewController: UICollectionViewController{
    // from apple developer
    private let productId = "com.ivaanteo-.Vibe"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Background
        collectionView.backgroundColor = .none
        configureGradientBackground()
        
        // Register Cell and Header
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        // StoreKit Delegate
        SKPaymentQueue.default().add(self)
    }
    
    func purchaseCoin(){
        if SKPaymentQueue.canMakePayments(){
            let paymentRequest = SKMutablePayment()
//            paymentRequest.productIdentifier = productIDs[id]
            paymentRequest.productIdentifier = productId
            SKPaymentQueue.default().add(paymentRequest)
            
        }else{
            
        }
    }
    
    @objc func purchaseButtonTapped(_ sender: UIButton){
        // check if purchased
//        let backgroundVibration = BackgroundVibrationManager.backgroundVibrations[sender.tag]
//        let vibrationId = backgroundVibration!.id
//        purchaseCoin(sender.tag)
        print("purchase \(sender.tag)")
    }
    
    @objc func restoreButtonTapped(_ sender: UIButton){
        print("restore button tapped")
        //restore vibration
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .init(white: 0.2, alpha: 0.5)
//        cell.largeContentTitle = "1 AuxCoin"
//        let backgroundVibration = BackgroundVibrationManager.backgroundVibrations[indexPath.row]
//        cell.purchaseButton.tag = backgroundVibration.id
//        cell.purchaseButton.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // buy
    }
    
    
}

extension PurchaseCoinsCollectionViewController: UICollectionViewDelegateFlowLayout{
//
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! ShopCollectionViewHeader
//        headerView.restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
//        return headerView
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: view.frame.width * 0.9,
//                      height:140)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

extension PurchaseCoinsCollectionViewController: SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState {
            case .purchased:
                print("purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
            
            case .purchasing:
                print("purchasing")
            case .failed:
                if let error = transaction.error{
                    print("Error: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                print("restored")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                print("deferred")
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                print("default")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
