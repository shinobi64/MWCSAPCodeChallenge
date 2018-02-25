//
//  DetailTableViewController.swift
//  Online
//
//  Copyright © 2017 SAP. All rights reserved.
//

import UIKit
import SAPFiori

class DetailTableViewController: UIViewController, Notifier, URLSessionTaskDelegate, UITextFieldDelegate, ActivityIndicator {

    private var product: MyPrefixProduct!
    private var activityIndicator: UIActivityIndicatorView!
    private var oDataModel: ODataModel?
    
    private var instructions: [String] = [
        "Open container",
        "Remove sealing",
        "Turn it off and on again"
    ]

    func initialize(oDataModel: ODataModel) {
        self.oDataModel = oDataModel
    }

    @IBOutlet var DetailTable: UITableView!

    /// Delegate function from UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        DetailTable.delegate = self
        DetailTable.dataSource = self
        
        DetailTable.allowsMultipleSelectionDuringEditing = true
        DetailTable.setEditing(true, animated: true)
        DetailTable.register(FUIObjectTableViewCell.self, forCellReuseIdentifier: "DetailCell")
        
        activityIndicator = initActivityIndicator()
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        showActivityIndicator(activityIndicator)
        
//        oDataModel?.openOfflineStore { result in
//            OperationQueue.main.addOperation {
////                self.loadData()
//            }
//        }
        if (product != nil) {
            let objectHeader = FUIObjectHeader() 
            //        objectHeader.detailImageView.image = #imageLiteral(resourceName: "ProfilePic")
            
            objectHeader.headlineLabel.text = product.name
            objectHeader.subheadlineText = product.categoryName
            objectHeader.descriptionText = product.longDescription

            DetailTable.tableHeaderView = objectHeader
            
        }
        
        hideActivityIndicator(activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// loads the current product
    ///
    /// - Parameter product: the current product
    func loadProduct(_ product: MyPrefixProduct) {
        self.product = product
    }

}

extension DetailTableViewController: UITableViewDataSource, UITableViewDelegate {
    /// Delegate function from UITableViewDataSource
    ///
    /// - Parameter tableView:
    /// - Returns: that this table only will have 1 section
    func numberOfSections(in _: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    /// Delegate function from UITableViewDataSource
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns: returns the number of rows the table should have
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return instructions.count // your number of cell here
    }
    
    /// Delegate function from UITableViewDataSource
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    /// - Returns: fills the cells with the Salesorder
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! FUIObjectTableViewCell
    
        let instruction = instructions[indexPath.row]
        
        cell.headlineText = "\(indexPath.row + 1). \(instruction)"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
    
    }
}

