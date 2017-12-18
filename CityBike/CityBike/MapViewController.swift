//
//  MapViewController.swift
//  CityBike
//
//  Created by Maharani on 15/12/17.
// Copyright © 2017 Maharani SVS. All rights reserved.
//

import UIKit
import MapKit

// MARK: - Alias Names
typealias jsonDict = Dictionary<String,Any>
typealias jsonArray = Array<jsonDict>

// MARK: - Service Response Keys
enum APIKeys: String {
    case bikeId = "id"
    case imgLink = "href"
    case companyName = "company"
    case bikeName = "name"
    case cityName = "city"
    case countryName = "country"
    case latitudePoint = "latitude"
    case longitudePoint = "longitude"
    case response = "networks"
    case location = "location"
    case respDetail = "network"
    case emptySlots = "empty_slots"
    case freebikes = "free_bikes"
}



class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    fileprivate var searchController: UISearchController!
    fileprivate var localSearchRequest: MKLocalSearchRequest!
    fileprivate var localSearch: MKLocalSearch!
    fileprivate var localSearchResponse: MKLocalSearchResponse!
    fileprivate var annotation: MKAnnotation!
    fileprivate var locationManager: CLLocationManager!
    fileprivate var isCurrentLocation: Bool = false
    var object : BikeDetail! ,stationObject : Stations!,isDetailedView = false
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.mapType = .standard
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        if isDetailedView == true {
            self.loadLoction(location: (stationObject?.locationDetails)!, country:(stationObject?.stationName)!, cit: "")
        } else {
            self.loadLoction(location: (object?.locationDetails.getLocation)!, country: (object?.locationDetails.country)!, cit: (object?.locationDetails.city)!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.center = self.view.center
    }
    
    // MARK: - Dismiss Action
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Actions to load Current Location in the Map
    @IBAction func currentLocationButtonAction(_ sender: Any) {
        if (CLLocationManager.locationServicesEnabled()) {
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            locationManager?.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //Need User Authorization to access current location
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            isCurrentLocation = true
        }
    }
    
    // MARK: - Action to Search Specific Locations
    @IBAction func searchButtonAction(_ sender: Any) {
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
        }
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    // MARK: - Search Action Delegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        //Use MKLocalSearch to find nearby points of interest within the region.It take MKLocalSearchRequest with natural language query as the search region and returns MKLocalResponse
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            if localSearchResponse == nil {
                let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self!.mapView.centerCoordinate = pointAnnotation.coordinate
            self!.mapView.addAnnotation(pinAnnotationView.annotation!)
        }
    }
    // MARK: - Action to load the location from Service inputs Co-ordinates
    func loadLoction(location  : CLLocationCoordinate2D, country : String , cit: String) {
        let latDelta: CLLocationDegrees = 0.01
        let lonDelta: CLLocationDegrees = 0.01
        //Use MKCoordinateSpan to extend from side to side Region.Then create the Region ,set and create required annotation in the map view.
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.mapView.setRegion(region, animated: true)
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = country
        annotation.subtitle = cit
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK: - CLLocationManagerDelegate for  continuously listen for location updates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isCurrentLocation {
            return
        }
        isCurrentLocation = false
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location!.coordinate
        pointAnnotation.title = ""
        mapView.addAnnotation(pointAnnotation)
    }
}

