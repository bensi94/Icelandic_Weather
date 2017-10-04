//
//  ViewController.swift
//  Veður
//
//  Created by Benedikt Óskarsson on 20/08/2017.
//  Copyright © 2017 Benzi. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    var appServer = AppServer()
    var requestAndPraser = WeatherRequestAndPraser()
    var closestStation: Station?
    
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
        }
        
        if let currentStation = closestStation {
            requestAndPraser.getObservasion(stationID: currentStation.stationNumber) { (inner: () throws -> observasion) -> Void in
                do {
                    let result = try inner()
                    print(self.closestStation?.name)
                    print(result)
                } catch _ {
                    
                }
            }
            
        }
        
        if let currentStation = closestStation {
            requestAndPraser.getForecast(stationID: currentStation.stationNumber) { (inner: () throws -> [foreCast?]) -> Void in
                do {
                    let result = try inner()
                    print(self.closestStation?.name)
                    print(result)
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

