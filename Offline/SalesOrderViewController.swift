//
//  SalesOrderViewController
//  Online
//
//  Copyright © 2016 SAP. All rights reserved.
//

import SAPFoundation
import UIKit
import SAPFiori

protocol SalesOrderViewControllerDelegate: class {
    func orderDidComplete(orderId: String)
}

class SalesOrderViewController: UIViewController, URLSessionTaskDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBAction func updateStatus(_ sender: Any) {
        do {
            try oDataModel!.updateSalesOrderHeader(status: "Close", currentSalesOrder: salesOrder)
            FUIToastMessage.show(message: "Ticket \(salesOrder.salesOrderID) completed.", maxNumberOfLines: 2)
            delegate?.orderDidComplete(orderId: salesOrder.salesOrderID ?? "")
            navigationController?.popViewController(animated: true)

        } catch  {
            let alert = UIAlertController(title: "Alert", message: "Updating the Status went south!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBOutlet var SalesOrderTable: UITableView!
    private var salesOrder: MyPrefixSalesOrderHeader!

    private var products = [MyPrefixProduct]()
    private var customers = [MyPrefixCustomer]()
    private var oDataModel: ODataModel?

    var delegate: SalesOrderViewControllerDelegate?
    
    func initialize(oDataModel: ODataModel) {
        self.oDataModel = oDataModel
    }

    /// delegate function from UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        SalesOrderTable.register(FUIObjectTableViewCell.self, forCellReuseIdentifier: "SalesOrderCell")
        SalesOrderTable.estimatedRowHeight = 80
        SalesOrderTable.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view
        oDataModel!.loadProdcutsForSalesOrder(salesOrder: salesOrder)  { resultProducts, error in

            if let tempProducts = resultProducts {
                self.products = tempProducts

            }
            OperationQueue.main.addOperation {
                self.SalesOrderTable.reloadData()

            }
        }
        
        if (salesOrder != nil) {
            // define some object header details
            let objectHeader = FUIObjectHeader()
            
            
            objectHeader.headlineLabel.text = "Inspection for \(salesOrder.customerDetails?.lastName ?? "TestCustomer")"
            objectHeader.subheadlineLabel.text = "Job \(salesOrder.salesOrderID ?? "1234")"
            
            objectHeader.tags = [FUITag(title: "\(salesOrder.lifeCycleStatusName ?? "Open")"), FUITag(title: "PM01"), FUITag(title: "103-Repair")]

            objectHeader.bodyLabel.numberOfLines = 2
            objectHeader.bodyText = "\(salesOrder.customerDetails?.postalCode ?? "69190") \(salesOrder.customerDetails?.city ?? "Walldorf")\n\(salesOrder.customerDetails?.street ?? "Altrottstraße 31")"
            
            objectHeader.descriptionText = "Temperature sensor predicts overheating failure. Urgent and needs attention!"
            objectHeader.descriptionLabel.text = "Temperature sensor predicts overheating in the next 3 days"
            
            objectHeader.footnoteText = "Due on 25th Feb. 2018"
            
            objectHeader.statusLabel.text = salesOrder.priority.rawValue
            
            switch salesOrder.priority {
            case .low:
                objectHeader.statusLabel.textColor = .preferredFioriColor(forStyle: .positive)
                break
            case .medium:
                break
            default:
                objectHeader.statusLabel.textColor = .preferredFioriColor(forStyle: .negative)
                break
            }

            SalesOrderTable.tableHeaderView = objectHeader

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SalesOrderTable.reloadData()
    }

    /// Delegate function from UITableViewDataSource
    ///
    /// - Parameter tableView:
    /// - Returns: that this table only will have 1 section
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    /// Delegate function from UITableViewDataSource
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns: returns the number of rows the table should have
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        // use the number of sales order items as each item has a assigned product
        return products.count
    }

    /// Delegate function from UITableViewDataSource
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    /// - Returns: fills the cells with the Sales order
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // make the object table cell
        let objectCell = tableView.dequeueReusableCell(withIdentifier: "SalesOrderCell", for: indexPath) as! FUIObjectTableViewCell
        
        let singleItem = products[indexPath.row]
        let item = salesOrder.items[indexPath.row]
        
        objectCell.headlineText = singleItem.name
        objectCell.subheadlineText = singleItem.productID
        objectCell.footnoteText = singleItem.categoryName
        
        if item.isComplete {
          objectCell.substatusText = "Completed"
          objectCell.substatusLabel.textColor = .preferredFioriColor(forStyle: .positive)
        } else {
          objectCell.substatusText = "Open"
          objectCell.substatusLabel.textColor = .preferredFioriColor(forStyle: .negative)
        }
        
        objectCell.accessoryType = .disclosureIndicator
        
        return objectCell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PartDetails", sender: indexPath)
    }

    /// Handler to prepare the segue
    ///
    /// - Parameters:
    ///   - segue:
    ///   - sender:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PartDetails" {
            
            let indexPath = sender as! IndexPath
            let product: MyPrefixProduct = products[indexPath.row]
            let item: MyPrefixSalesOrderItem = salesOrder.items[indexPath.row]
            let pViewControler = segue.destination as! DetailTableViewController
            pViewControler.initialize(oDataModel: oDataModel!)
            pViewControler.delegate = self
            pViewControler.loadProduct(product)
            pViewControler.loadItem(item)
        }
    }
    /// loads the current salesorderItem
    ///
    /// - Parameter newItems: the current salesorderItem
    public func loadSalesOrderItems(newItem: MyPrefixSalesOrderHeader) {
        salesOrder = newItem
    }

}

extension SalesOrderViewController: DetailTableViewControllerDelegate {
    func itemDidComplete(partId: Int) {
        for item in salesOrder.items {
            if item.itemNumber == partId {
                item.isComplete = true
                SalesOrderTable.reloadData()
                break
            }
        }
    }
}
