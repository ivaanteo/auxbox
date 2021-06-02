//
//  SearchResultsErrorViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 6/5/21.
//

import UIKit

class SearchResultsErrorViewController: UIViewController{
    let errorLabel = UILabel()
    var errorText:String?{
        didSet{
            errorLabel.text = errorText
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(errorLabel)
    }
}
