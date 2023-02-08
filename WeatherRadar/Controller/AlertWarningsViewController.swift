//
//  AlertWarningsViewController.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 17/4/2022.
//

import UIKit
import Foundation
import CoreLocation
import MapKit
import GoogleMaps
import GoogleMapsUtils

// structure for having an annotation mark on the google map
struct MarkerAnnotation {
    let name: String
    let lat: CLLocationDegrees
    let lon: CLLocationDegrees
}

class AlertWarningsViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    // mapview
    @IBOutlet weak var mapView: GMSMapView!
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var list = [GMUWeightedLatLng]()
    
    private var mapMarkers: [GMSMarker] = []
    
    // gradient
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.2,1.0] as [NSNumber]
    
    var weather: WeatherModel?
    
    weak var databaseController: DatabaseProtocol?
    
    // see reference in about page controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the heatmap settings
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 500
        heatmapLayer.opacity = 0.5
        heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints, colorMapSize: 256)
        heatmapLayer.map = mapView
        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // checks if weather isn't nil when parsed over from the segue
        if let weather = weather {
            // This property must be key-value observable, which the `@objc dynamic` attributes provide.
            let annotationLocations = [MarkerAnnotation(name: weather.cityName, lat: weather.lat, lon: weather.lon)]
            
            // sets the map onto the screen
            // camera lets us see what the user views when opening on the map
            mapView.camera = GMSCameraPosition.camera(withLatitude: weather.lat, longitude: weather.lon, zoom: 15)
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
            print("mapView")
            print(mapView)
            

            // makes a heatmap
            updateHeatMap(lat: weather.lat, lon: weather.lon)
            // creates an annotation on the map to show where user is on map or the city they are viewing
            createAnnotations(locations: annotationLocations)
            

        // Do any additional setup after loading the view.
        }
        
        AppUtility.lockOrientation(.all)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // reset back to only portrait
        AppUtility.lockOrientation(.portrait)
    }
    
    // how to update and make a heat map appear on map
    func updateHeatMap(lat: Double, lon: Double){
        // set the coordinates
        let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lon as! CLLocationDegrees), intensity: 1.0)
        // update our list with new coordnates
        list.append(coords)
        // add these coordinates to the heatmap layer
        heatmapLayer.weightedData = list
        // update the overlay
        heatmapLayer.map = mapView
        // updates the heatmap live
        heatmapLayer.clearTileCache()
    }

    // how to create an annotation to be put on the map
    func createAnnotations(locations: [MarkerAnnotation]) {
        // check if location isn't nil
        for location in locations {
            // set location position
            let position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            // initialise location marker
            let locationmarker = GMSMarker(position: position)
            // have annotation title on marker
            locationmarker.title = location.name
            // update the mapview
            locationmarker.map = mapView
            // append it to the mapMarkers list
            mapMarkers.append(locationmarker)
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}
