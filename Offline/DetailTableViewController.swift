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
//            objectHeader.subheadlineLabel.text = "\(salesOrderItem.price!.toString()) \(String(describing: salesOrderItem.currencyCode))"
//            objectHeader.footnoteLabel.text = salesOrderItem.categoryName
//            objectHeader.descriptionLabel.text = salesOrderItem.longDescription
//
//            objectHeader.statusLabel.text = salesOrderItem.supplierID
            DetailTable.tableHeaderView = objectHeader
            
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! EditableCell
        
        let  instruction = instructions[indexPath.row]
        
        cell.textLabel?.text = "\(indexPath.row + 1). \(instruction)"
//        cell.detailTextLabel?.text = (singleProduct.price?.toString())! + singleProduct.currencyCode!
        
        //        switch indexPath.row {
        //        case 0:
        //            cell.unitLabel?.text = salesOrderItem.dimensionUnit
        //            cell.titleLabel.text = "Depth"
        //            cell.valueTextField.text = salesOrderItem.dimensionDepth?.toString()
        //            break
        //        case 1:
        //            cell.unitLabel?.text = salesOrderItem.dimensionUnit
        //            cell.titleLabel.text = "Width"
        //            cell.valueTextField.text = salesOrderItem.dimensionWidth?.toString()
        //            break
        //        case 2:
        //            cell.unitLabel?.text = salesOrderItem.dimensionUnit
        //            cell.titleLabel.text = "Height"
        //            cell.valueTextField.text = salesOrderItem.dimensionHeight?.toString()
        //            break
        //        default: break
        //
        //        }
//        cell.valueTextField.allowsEditingTextAttributes = false
        
        return cell
        
    }
}

