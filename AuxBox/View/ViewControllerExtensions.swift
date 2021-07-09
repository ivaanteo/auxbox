//
//  ViewControllerExtensions.swift
//  AuxBox
//
//  Created by Ivan Teo on 6/7/21.
//

import UIKit

extension UIViewController{
    func showActivityIndicator(activityView: UIActivityIndicatorView) {
        activityView.style = .large
        activityView.color = .white
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }

    func hideActivityIndicator(activityView: UIActivityIndicatorView){
        activityView.stopAnimating()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

