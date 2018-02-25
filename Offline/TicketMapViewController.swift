//  SAP Fiori for iOS Mentor
//  SAP Cloud Platform SDK for iOS Code Example
//  Marker Annotation View
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.

import SAPFiori
import MapKit

class TicketMapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    // set the location to the SAP Headquarters: Dietmar-Hopp-Allee 16, 69190 Walldorf DE
    let location = CLLocationCoordinate2D(latitude: 49.293843, longitude: 8.641369)
    
    let latitudinalMeters = 1_000_000.0
    let longitudinalMeters = 1_000_000.0
    
    var salesOrders: [MyPrefixSalesOrderHeader]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            
            // the FUIMarkerAnnotationView is only available in iOS 11
            class FioriMarker: FUIMarkerAnnotationView {
                override var annotation: MKAnnotation? {
                    willSet {
                        markerTintColor = .preferredFioriColor(forStyle: .map1)
                        glyphImage = FUIIconLibrary.map.marker.venue.withRenderingMode(.alwaysTemplate)
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
                
                self.mapView.addAnnotation(annotation)
            }
            
        }
        
        // center map
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
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

