//
//  ViewController.swift
//  Veður
//
//  Created by Benedikt Óskarsson on 20/08/2017.
//  Copyright © 2017 Benzi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    var appServer = AppServer()
    var requestAndPraser = WeatherRequestAndPraser()
    var closestStation: Station?
    @IBOutlet weak var townLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var windDirectionLbl: UILabel!
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var heatLbl: UILabel!
    @IBOutlet weak var stasionLbl: UILabel!
    @IBOutlet weak var weatherDescriptionLbl: UILabel!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var smallestDistance: CLLocationDistance?
        var tempStation = Station()
        
        //When we get the location, we calculate which station is closest to the user location
        if let userLocation = manager.location {
            for station in appServer.getStations() {
                let location = CLLocation(latitude: station.latitude, longitude: station.longitude)
                let distance = userLocation.distance(from: location)
                if smallestDistance == nil || distance < smallestDistance! {
                    smallestDistance = distance
                    tempStation = station
                }
            }
            closestStation = tempStation
            appServer.lookUpCurrentLocation(location: userLocation){(placemark) in
                if let placemark = placemark {
                    self.townLbl.text = placemark.thoroughfare
                    self.areaLbl.text = placemark.locality
                }
                
            }
        }
        
        if let currentStation = closestStation {
            self.stasionLbl.text = "Veðurstöð: " + currentStation.name
            requestAndPraser.getObservasion(stationID: currentStation.stationNumber) { (inner: () throws -> observasion) -> Void in
                do {
                    let result = try inner()
                    self.windDirectionLbl.text = self.requestAndPraser.windDirection(direction: result.windDerction)
                    if(result.windDerction == "Logn"){
                        self.windSpeedLbl.text =  "0 m/s"
                    } else {
                        self.windSpeedLbl.text = result.windSpeed + " m/s"
                    }
                    self.heatLbl.text = result.temperature.replacingOccurrences(of: ",", with: ".") + "°C"
                    self.weatherDescriptionLbl.text = self.requestAndPraser.descriptionToIcon(description: result.weatherDescription)
                } catch _ {
                    
                }
            }
            
        }
        
        if let currentStation = closestStation {
            requestAndPraser.getForecast(stationID: currentStation.stationNumber) { (inner: () throws -> [foreCast?]) -> Void in
                do {
                    let result = try inner()
                    for res in result {
                        
                        
                    }
                } catch _ {
                    
                }
            }
            
        }

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appServer.loadStations()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

