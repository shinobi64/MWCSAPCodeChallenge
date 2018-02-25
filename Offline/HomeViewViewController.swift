//
//  HomeViewViewController.swift
//  Offline
//
//  Created by Lechner, Sami on 07.02.18.
//  Copyright © 2018 SAP. All rights reserved.
//

import UIKit
import SAPFiori

class HomeViewViewController: UIViewController, URLSessionTaskDelegate, ActivityIndicator {
    
    
    @IBOutlet weak var HomeTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    private var oDataModel: ODataModel?
    private var salesOrders = [MyPrefixSalesOrderHeader]()
    private var filteredSalesOrders = [MyPrefixSalesOrderHeader]()
    private var activityIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    private let objectCellId = "SalesOrderCellID"
    private var filterFeedbackControl: FUIFilterFeedbackControl!
    private var categoryGroup = FUIFilterGroup()
    
    let categoryItemHigh = FUIFilterItem("High", isFavorite: true, isActive: false)
    
    let categoryItemLow = FUIFilterItem("Low", isFavorite: true, isActive: false)
    
    let categoryItemMedium = FUIFilterItem("Medium", isFavorite: true, isActive: false)
    
    func initialize(oDataModel: ODataModel) {
        self.oDataModel = oDataModel
    }


    override func viewDidLoad() {
        HomeTableView.dataSource = self
        HomeTableView.delegate = self
        super.viewDidLoad()
        activityIndicator = initActivityIndicator()
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        showActivityIndicator(activityIndicator)
        
        oDataModel?.openOfflineStore { result in
            OperationQueue.main.addOperation {
                self.loadData()
            }
        }
        HomeTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshOfflineData(_:)), for: .valueChanged)
        HomeTableView.register(FUIObjectTableViewCell.self, forCellReuseIdentifier: objectCellId)
        
        setupCategoryGroups()
        setupFilterFeedback()
    }
    
    @objc private func refreshOfflineData(_ sender: Any) {
        // Fetch Weather Data
        self.oDataModel?.downloadOfflineStore{ error in
            
            OperationQueue.main.addOperation {
                self.loadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCategoryGroups() {
        
        categoryGroup.items = [
            categoryItemHigh,
            categoryItemLow,
            categoryItemMedium
        ]
        
        categoryGroup.isMutuallyExclusive = true
        categoryGroup.allowsEmptySelection = true
    }
    
    func setupFilterFeedback() {
        
        let frameFilterFeedback = CGRect(x: 0, y: 0, width: filterView.frame.width, height: 44)
        
        let filterFeedbackControl = FUIFilterFeedbackControl(frame: frameFilterFeedback)
        filterFeedbackControl.filterGroups = [categoryGroup]
        filterFeedbackControl.filterResultsUpdater = self
        
        filterView.addSubview(filterFeedbackControl)
    }
    
    /// Handler to prepare the segue
    ///
    /// - Parameters:
    ///   - segue:
    ///   - sender:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TicketDetails" {
            let indexPath = sender as! IndexPath
            let order: MyPrefixSalesOrderHeader = filteredSalesOrders[indexPath.row]
            let sOviewControler = segue.destination as! SalesOrderViewController
            sOviewControler.initialize(oDataModel: oDataModel!)
            sOviewControler.loadSalesOrderItems(newItem: order)
            
        }
        
    }
    private func loadData() {
        self.oDataModel!.loadSalesOpenOrders { resultSalesOrders, error in
            
            if error != nil {
                // handle error in future version
            }
            if let tempSalesOrders = resultSalesOrders {
                for salesOrder in tempSalesOrders {
                    let randomNumber = arc4random_uniform(_: 3)
                    switch randomNumber {
                    case 0:
                        salesOrder.priority = .low
                        break
                    case 1:
                        salesOrder.priority = .medium
                        break
                    default:
                        salesOrder.priority = .high
                        break
                    }
                }
                
                
                self.salesOrders = tempSalesOrders
                self.filteredSalesOrders = tempSalesOrders
            }
            OperationQueue.main.addOperation {
                self.HomeTableView.reloadData()
                
            }
            self.hideActivityIndicator(self.activityIndicator)
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    /// the function corrects the data to reflect the challange at the MVC 2017
    @IBAction func resetData(_ sender: Any) {

//        for equipment in products {
//            var dirty = false;
//            switch equipment.category {
//
//            case "Portable Players"?, "Graphic Cards"?:
//                let newCategory : String = "Control System"
//                equipment.categoryName = newCategory
//                equipment.category = newCategory
//                equipment.name = equipment.name?.replacingOccurrences(of: "DVD Player", with: "Controler")
//                dirty = true;
//                break;
//            case "Scanners"?, "Keyboards"?:
//                let newCategory : String = "Radio Scanners"
//                equipment.categoryName = newCategory
//                equipment.category = newCategory
//                equipment.name = equipment.name?.replacingOccurrences(of: "Photo", with: "Radio")
//                equipment.shortDescription = equipment.shortDescription?.replacingOccurrences(of: "Flatbed", with: "Radio")
//                equipment.longDescription = equipment.longDescription?.replacingOccurrences(of: "Flatbed", with: "Radio")
//                dirty = true;
//                break;
//            case "MP3 Players"?, "Mousepads"? , "Mice"?:
//                let newCategory : String = "Antenna"
//                equipment.categoryName = newCategory
//                equipment.category = newCategory
//                equipment.name = equipment.name?.replacingOccurrences(of: "Player", with: "Antenna")
//                equipment.name = equipment.name?.replacingOccurrences(of: "Mousepad", with: "Antenna")
//                equipment.shortDescription = equipment.shortDescription?.replacingOccurrences(of: "MP3 Players", with: "Antenna")
//                equipment.longDescription = equipment.longDescription?.replacingOccurrences(of: "MP3 Players", with: "Antenna")
//                dirty = true;
//                break;
//            case "Notebooks"?, "Multifunction Printers"?:
//                let newCategory : String = "Transceiver"
//                equipment.categoryName = newCategory
//                equipment.category = newCategory
//                equipment.name = equipment.name?.replacingOccurrences(of: "Notebook", with: "Transceiver")
//                equipment.shortDescription = equipment.shortDescription?.replacingOccurrences(of: "Notebook", with: "Transceiver")
//                equipment.longDescription = equipment.longDescription?.replacingOccurrences(of: "Notebook", with: "Transceiver")
//                dirty = true;
//                break;
//            case "Software"?:
//                let newCategory : String = "Power Amplifier"
//                equipment.categoryName = newCategory
//                equipment.category = newCategory
//                equipment.name =  "Power Amplifier"
//                dirty = true;
//                break;
//            case "Projectors"?, "Ink Jet Printers"?:
//                let newCategory : String = "Multiplexer"
//                equipment.categoryName = newCategory
//                equipment.category = newCategory
//                dirty = true;
//                break;
//            case "Tablets"?, "Flat Screen TVs"?, "Flat Screen Monitors"?:
//                let newCategory : String = "Solar Panel"
//                equipment.categoryName = newCategory
//                equipment.category = newCategory
//                equipment.name = "Solar Panel"
//                dirty = true;
//                break;
//            case "PCs"?, "Laser Printers"?:
//                let newCategory : String = "Diesel Generator"
//                equipment.categoryName = newCategory
//                equipment.category = newCategory
//                equipment.name = equipment.name?.replacingOccurrences(of: "PC", with: "Diesel Generator")
//                dirty = true;
//                break;
//
//            default :
//                break
//            }
//            if(dirty){
//                do {
//                    try oDataModel?.updateProduct(currentProduct: equipment)
//                }
//                catch{
//                    let alert = UIAlertController(title: "Alert", message: "Updating Product went south!", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
//                        NSLog("The \"OK\" alert occured.")
//                    }))
//                }
//            }
//        }
    }
    
}

extension HomeViewViewController: UITableViewDelegate, UITableViewDataSource {
    /// Delegate function from UITableViewDataSource
    ///
    /// - Parameter tableView:
    /// - Returns: that this table only will have 1 section
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSalesOrders.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenTicketCell", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: objectCellId,
                                                 for: indexPath as IndexPath) as! FUIObjectTableViewCell
        if indexPath.section == 0 {
            let singleOrder = filteredSalesOrders[indexPath.row]
            
            cell.headlineText = singleOrder.salesOrderID
            cell.footnoteText = "\(singleOrder.customerDetails?.street ?? ""), \(singleOrder.customerDetails?.city ?? "")"
            cell.statusText = singleOrder.priority.rawValue.capitalized
            cell.accessoryType = .disclosureIndicator
            //            objectCell.headlineText = "Speed Mouse"
            //            objectCell.subheadlineText = "HT-1061"
            //            objectCell.footnoteText = "Computer Components"
            //            objectCell.descriptionText = "Optical USB, PS/2 Mouse, Color: Blue, 3-button-functionality (incl. Scroll wheel)"
            //            objectCell.detailImage = UIImage() // TODO: Replace with your image
            //            objectCell.detailImage?.accessibilityIdentifier = "Speed Mouse"
            
            //            objectCell.substatusText = "In Stock"
            //            objectCell.substatusLabel.textColor = .preferredFioriColor(forStyle: .positive)
            
            //            objectCell.splitPercent = CGFloat(0.3)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "openTickets"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TicketDetails", sender: indexPath)
    }
}

extension HomeViewViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != ""
            else {
                filteredSalesOrders = salesOrders
                HomeTableView.reloadData()
                return
        }
        
        filteredSalesOrders = salesOrders.filter { ( salesOrder ) -> Bool in
            let lowerCasedSearchText = searchText.lowercased()
            return salesOrder.salesOrderID?.lowercased().range(of: lowerCasedSearchText) != nil ||
                    salesOrder.customerDetails?.street?.lowercased().range(of: lowerCasedSearchText) != nil ||
                    salesOrder.customerDetails?.city?.lowercased().range(of: lowerCasedSearchText) != nil ||
                    salesOrder.priority.rawValue.range(of: lowerCasedSearchText) != nil
        }
        HomeTableView.reloadData()
    }
    
}

extension HomeViewViewController: FUIFilterResultsUpdating {
    
    func updateFilterResults(for filterFeedbackControl: FUIFilterFeedbackControl) {
        
        // reset the sales orders to their initial state
        // this means no filters are applied
        // and the products are sorted by name
        filteredSalesOrders = salesOrders
        
        let activeFilterItems = filterFeedbackControl.filterItems.filter({ $0.isActive })
        
        // search if one of the filters is contained in the activeFilters
        // and apply it, then break out of the loop
        // because only one category filter can be active
        for filterItem in categoryGroup.items {
            
            if activeFilterItems.contains(filterItem) {
                
                filteredSalesOrders = salesOrders.filter { salesOrder in
                    salesOrder.priority.rawValue == filterItem.title.lowercased()
                }
                break
            }
        }
        
        HomeTableView.reloadData()
    }
}
