//  SAP Fiori for iOS Mentor
//  SAP Cloud Platform SDK for iOS Code Example
//  Marker Annotation View
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.

import SAPFiori
import MapKit

class TicketMapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    var startLocation: CLLocation?
    
    let latitudinalMeters = 1_000_000.0
    let longitudinalMeters = 1_000_000.0
    
    var pinAnnotationView: MKPinAnnotationView!
    var salesOrders: [MyPrefixSalesOrderHeader]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            
            // the FUIMarkerAnnotationView is only available in iOS 11
            class FioriMarker: FUIMarkerAnnotationView {
                override var annotation: MKAnnotation? {
                    willSet {
                        markerTintColor = .preferredFioriColor(forStyle: .map1)
                        glyphImage = FUIIconLibrary.map.marker.inProcess.withRenderingMode(.alwaysTemplate)
                        displayPriority = .defaultHigh
                    }
                }
            }
            
            mapView.register(FioriMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
        
        for salesOrder in salesOrders {
            
            let geoCoder = CLGeocoder()
            
            geoCoder.geocodeAddressString("\(salesOrder.customerDetails?.street ?? ""), \(salesOrder.customerDetails?.city ?? "")") { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else {
                        // handle no location found
                        return
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = salesOrder.salesOrderID
                
                self.pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                self.pinAnnotationView.canShowCallout = true
                
                if self.startLocation == nil {
                    self.startLocation = location
                }
                
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            }
            
        }
        
        // center map
        guard let startCoordinate = startLocation?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(startCoordinate,
                                                                  latitudinalMeters,
                                                                  longitudinalMeters)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    /// loads the current salesorderItem
    ///
    /// - Parameter newItems: the current salesorderItem
    public func loadSalesOrders(newItem: [MyPrefixSalesOrderHeader]) {
        salesOrders = newItem
    }
}

extension TicketMapViewController: MKMapViewDelegate {
    
}
