//
//  MapViewController.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/16/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mainMapView: MKMapView!
    var itemToSearch: String?
    var matchingItems = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainMapView.showsUserLocation = true
        self.mainMapView.delegate = self
        if itemToSearch != nil{
            var formattedQuery = itemToSearch!.stringByReplacingOccurrencesOfString(" (DM)", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
            if var rangeToDelete = formattedQuery.rangeOfString(","){
                var rangeOfTittle = Range(start: formattedQuery.startIndex, end:  rangeToDelete.startIndex)
                var tittle = formattedQuery.substringWithRange(rangeOfTittle)
                println(tittle)
                self.title = tittle
            }else{
                self.title = formattedQuery
            }
            performSearch("\(formattedQuery), Republica Dominicana")
        }
    }
    
    func performSearch(itemToSearch: String){
        println("Buscando coincidencias con \(itemToSearch)")
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = itemToSearch
        request.region = mainMapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler { (response: MKLocalSearchResponse!, error: NSError!) in
            if error != nil{
                println("Error encontrado buscando: \(error.localizedDescription)")
            }else if response.mapItems.count ==  0 {
                println("No rutas encontradas")
                let alert = UIAlertView()
                alert.title = "No encontrado"
                alert.message = "No se pudo encontrar \(self.title!)"
                alert.addButtonWithTitle("Aceptar")
                alert.show()
            }else{
                println("Coincidencias encontradas")
                for item in response.mapItems as [MKMapItem]{
                    self.matchingItems.append(item as MKMapItem)
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.mainMapView.addAnnotation(annotation)
                }
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func generateRoutes(){
        let request = MKDirectionsRequest()
        request.setSource(MKMapItem.mapItemForCurrentLocation())
        request.setDestination(self.matchingItems[0])
        request.requestsAlternateRoutes = false
        request.transportType = MKDirectionsTransportType.Any
        let directions = MKDirections()
        directions.calculateDirectionsWithCompletionHandler({(response: MKDirectionsResponse!, error: NSError!) in
            if error != nil{
                println("Error getting routes: \(error.localizedDescription)")
            }else{
                self.showRoutes(response)
            }
        })
    }
    
    func showRoutes(response: MKDirectionsResponse){
        for route in response.routes as [MKRoute]{
            self.mainMapView.addOverlay(route.polyline)
        }
    }
    
    func zoom(amountOfZoom zoomAmount: Double){
        var coordinates: CLLocationCoordinate2D?
        if self.matchingItems.count > 0{
            coordinates = self.matchingItems.first?.placemark.coordinate
        }else{
            coordinates = MKMapItem.mapItemForCurrentLocation().placemark.coordinate
        }
        var mapCamera = MKMapCamera(lookingAtCenterCoordinate: coordinates!, fromEyeCoordinate: coordinates!, eyeAltitude: zoomAmount)
        self.mainMapView.setCamera(mapCamera, animated: true)
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        if self.matchingItems.count > 0 {
            self.generateRoutes()
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline{
            var polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = UIColor.blueColor()
            polylineRender.lineWidth = 5
            return polylineRender
        }
        return nil
    }
    
    @IBAction func zoomIn(sender: AnyObject) {
        var altitude = self.mainMapView.camera.altitude as CLLocationDistance
        altitude = altitude - (altitude * 0.8)
        self.zoom(amountOfZoom: altitude)
    }
    
    @IBAction func zoomOut(sender: AnyObject) {
        var altitude = self.mainMapView.camera.altitude as CLLocationDistance
        altitude = altitude + (altitude * 1)
        self.zoom(amountOfZoom: altitude)
    }
    
    @IBAction func closeModal(sender: UIBarButtonItem) {
        if UIApplication.sharedApplication().networkActivityIndicatorVisible == true{
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
