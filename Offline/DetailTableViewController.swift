//
//  DetailTableViewController.swift
//  Online
//
//  Copyright © 2017 SAP. All rights reserved.
//

import UIKit
import SAPFiori

protocol DetailTableViewControllerDelegate: class {
    func itemDidComplete(partId: Int)
}

class DetailTableViewController: UIViewController, Notifier, URLSessionTaskDelegate, UITextFieldDelegate, ActivityIndicator {
    
    private var product: MyPrefixProduct!
    private var item: MyPrefixSalesOrderItem!
    private var activityIndicator: UIActivityIndicatorView!
    private var oDataModel: ODataModel?
    var delegate: DetailTableViewControllerDelegate?
    
    private var instructions:[(description: String, isComplete: Bool)] = [
        ("Open container", false),
        ("Remove sealing", false),
        ("Turn it off and on again", false)
    ]

    func initialize(oDataModel: ODataModel) {
        self.oDataModel = oDataModel
    }

    @IBAction func completeItem(_ sender: Any) {
        self.item.isComplete = true
        if let itemNo = self.item.itemNumber {
            FUIToastMessage.show(message: "Item \(itemNo) has been completed.")
            delegate?.itemDidComplete(partId: itemNo)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBOutlet var DetailTable: UITableView!

    /// Delegate function from UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        DetailTable.delegate = self
        DetailTable.dataSource = self
        
        DetailTable.register(FUITimelineCell.self, forCellReuseIdentifier: "DetailCell")
        DetailTable.estimatedRowHeight = 44
        DetailTable.rowHeight = UITableViewAutomaticDimension
        
        DetailTable.backgroundColor = UIColor.preferredFioriColor(forStyle: .backgroundBase)
        DetailTable.separatorStyle = .none
        
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

    /// loads the current item
    ///
    /// - Parameter product: the current item
    func loadItem(_ item: MyPrefixSalesOrderItem) {
        self.item = item
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! FUITimelineCell
    
        let instruction = instructions[indexPath.row]
        
        cell.headlineText = instruction.description
        cell.eventText = "Step \(indexPath.row + 1)"
        
        if instruction.isComplete {
            cell.eventImage = FUIIconLibrary.system.check
        }
        
        cell.nodeImage = UIImage()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // return an add to cart action for when the user swipes left on the cell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let markAsComplete = UITableViewRowAction( style: .normal, title: "Mark as complete") { _, _ in
            
            // remove swiped-in button
            tableView.setEditing(false, animated: true)
            self.instructions[indexPath.row].isComplete = true
            tableView.reloadData()
            
        }
        
        // set color of swiped-in button
        markAsComplete.backgroundColor = .preferredFioriColor(forStyle: .tintColorDark)
        
        return [markAsComplete]
        
    }
    
}

