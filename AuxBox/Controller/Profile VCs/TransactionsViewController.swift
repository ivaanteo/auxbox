//
//  TransactionsViewController.swift
//  AuxBox
//
//  Created by Ivan Teo on 7/7/21.
//

import UIKit

class TransactionsViewController: UIViewController{
    var segmentedControlTabs = ["As Host", "As Guest"]
    var segmentedControl: UISegmentedControl!
    var tableView: UITableView!
//    var transactionList = [TransactionViewModel(date: "31 Jul 2021", songName: "Billy Jean", artist: "Michael Jackson"),
//                           TransactionViewModel(date: "31 Jul 2021", songName: "Billy Jean", artist: "Michael Jackson"),
//                           TransactionViewModel(date: "31 Jul 2021", songName: "Billy Jean", artist: "Michael Jackson"),
//                           TransactionViewModel(date: "31 Jul 2021", songName: "Billy Jean", artist: "Michael Jackson"),
//                           TransactionViewModel(date: "31 Jul 2021", songName: "Billy Jean", artist: "Michael Jackson")]
    var hostTxnList = [TransactionViewModel]()
    var guestTxnList = [TransactionViewModel]()
    let errorLabel = UILabel()
    
    let hostErrorText = "Oops, looks like you haven't earned any AuxCoins from hosting rooms."
    let guestErrorText = "No AuxCoins transacted. Try out premium queue to get started."
    let loadingSpinner = UIActivityIndicatorView()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        title = "Transactions"
        view.backgroundColor = UIColor(named: "bgColour")
        layoutSegmentedControl()
        layoutTableView()
        showActivityIndicator(activityView: loadingSpinner)
        getTransactions(segmentedControlIndex: 0)
        getTransactions(segmentedControlIndex: 1)
    }
    
    
    func getTransactions(segmentedControlIndex: Int){
        DatabaseManager.shared.fetchTransactions(isHost: segmentedControlIndex==0) { (res) in
            switch res{
            case .success(let txnList):
                
                if segmentedControlIndex == 0{
                    self.hostTxnList = txnList
                }else{
                    self.guestTxnList = txnList
                }
                DispatchQueue.main.async {
                    // on first load, want to update error message
                    // check if current tab is that of what's being called
                    // this prevents running twice
                    if self.segmentedControl.selectedSegmentIndex == segmentedControlIndex{
                        if self.segmentedControl.selectedSegmentIndex == 0 && self.hostTxnList.isEmpty{
                            self.errorLabel.setupLabel(displayText: self.hostErrorText, fontSize: 24, centerAlign: true)
                            self.tableView.backgroundView = self.errorLabel
                        }else if self.segmentedControl.selectedSegmentIndex == 1 && self.hostTxnList.isEmpty{
                            self.errorLabel.setupLabel(displayText: self.guestErrorText, fontSize: 24, centerAlign: true)
                            self.tableView.backgroundView = self.errorLabel
                        }else{
                            // is not empty
                            // set to none in case user clicks on one of the tabs, which triggers the error message
                            self.tableView.backgroundView = .none
                        }
                        if self.loadingSpinner.isAnimating{
                            self.hideActivityIndicator(activityView: self.loadingSpinner)
                        }
                    }
                    self.tableView.reloadData()
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.showAlert(title: "Oops", message: "Failed to retrived transactions \(err.localizedDescription)")
                    if self.loadingSpinner.isAnimating{
                        self.hideActivityIndicator(activityView: self.loadingSpinner)
                    }
                }
            }
        }
    }
    
    @objc func segmentedControlHandler(sender: UISegmentedControl!){
        if sender.selectedSegmentIndex == 1{
            DispatchQueue.main.async {
                sender.selectedSegmentTintColor = UIColor(named: K.Colours.orange)
                if !self.guestTxnList.isEmpty{
                    self.tableView.backgroundView = .none
                }else{
                    self.errorLabel.text = self.guestErrorText
                    self.tableView.backgroundView = self.errorLabel
                }
                self.tableView.reloadData()
            }
            
        }else{
            DispatchQueue.main.async {
                sender.selectedSegmentTintColor = UIColor(named: K.Colours.purple)
                if !self.hostTxnList.isEmpty{
                    self.tableView.backgroundView = .none
                }else{
                    self.errorLabel.text = self.hostErrorText
                    self.tableView.backgroundView = self.errorLabel
                }
                self.tableView.reloadData()
//                self.updateTableView(segmentedControlIndex: sender.selectedSegmentIndex)
            }
        }
    }
    
    private func layoutTableView(){
        tableView = UITableView()
        tableView.backgroundColor = .none
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: TransactionsTableViewCell.cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.allowsSelection = false
    }
    
    
    private func layoutSegmentedControl(){
        segmentedControl = UISegmentedControl(items: segmentedControlTabs)
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.backgroundColor = .none
        segmentedControl.selectedSegmentTintColor = UIColor(named: K.Colours.purple)
        segmentedControl.setTitleTextAttributes([.font: UIFont(name: "Futura", size: 12)!, .foregroundColor: UIColor.white], for: .normal)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(segmentedControlHandler), for: .valueChanged)
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        segmentedControl.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
    }
    
}

extension TransactionsViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? hostTxnList.count : guestTxnList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
extension TransactionsViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsTableViewCell.cellId) as! TransactionsTableViewCell
        //        cell.textLabel?.text = "Hello"
        //        cell.backgroundColor = .black
        //        cell.textLabel?.textColor = .white
        if segmentedControl.selectedSegmentIndex == 0{
            cell.viewModel = hostTxnList[indexPath.row]
        }else{
            cell.viewModel = guestTxnList[indexPath.row]
        }
        cell.asHost = (segmentedControl.selectedSegmentIndex == 0)
        return cell
    }
}
