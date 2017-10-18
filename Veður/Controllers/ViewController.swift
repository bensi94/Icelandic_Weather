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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appServer.loadStations()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    //The reason we do a lot of the logic inside this function is that we want the app to update everything depending on the user location
    //so when the location changes we need to update most of the app, also we want the app to keep on updateing the information if the location is not changeing
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //When we get the location, we calculate which station is closest to the user location
        if let userLocation = manager.location {
            closestStation = getCurrentStasion(userLocation: userLocation)
            updatePlaceMarks(userLocation: userLocation)
        }
        
        //If we have our closest stasion we send the requests to get our weather information and update our lables
        if let currentStation = closestStation {
            self.stasionLbl.text = "Veðurstöð: " + currentStation.name
            updateWeatherLbls(observ: getObservasion(stationID: currentStation.stationNumber), forecast: getForeCast(stationID: currentStation.stationNumber))
            
        }
        
    }
    
    func getCurrentStasion(userLocation: CLLocation) -> Station {
        var smallestDistance: CLLocationDistance?
        var tempStation = Station()
        for station in appServer.getStations() {
            let location = CLLocation(latitude: station.latitude, longitude: station.longitude)
            let distance = userLocation.distance(from: location)
            if smallestDistance == nil || distance < smallestDistance! {
                smallestDistance = distance
                tempStation = station
            }
        }
        
        return tempStation
    }
    
    func updatePlaceMarks(userLocation: CLLocation) {
        appServer.lookUpCurrentLocation(location: userLocation){(placemark) in
            //If we found our loactaion we assign our placemarks here, we do checks if we find the placemark we want if not we take backup option
            if let placemark = placemark {
                if let thoroughfare = placemark.thoroughfare {
                    self.townLbl.text = thoroughfare
                } else {
                    self.townLbl.text = placemark.name
                }
                
                if let locality = placemark.locality{
                    self.areaLbl.text = locality
                } else {
                    self.areaLbl.text = placemark.country
                }
            }
            
        }
    }
    
    func getObservasion(stationID: Int) -> observasion? {
        var returnObser: observasion?
        requestAndPraser.getObservasion(stationID: stationID) { (inner: () throws -> observasion) -> Void in
            do {
                let result = try inner()
                returnObser = result
                
            } catch _ {
                
            }
        }
        return returnObser
    }
    
    func getForeCast(stationID: Int) -> [foreCast?]? {
        var returnForec: [foreCast?]?
        requestAndPraser.getForecast(stationID: stationID) { (inner: () throws -> [foreCast?]) -> Void in
            do {
                let result = try inner()
                returnForec = result
            } catch _ {
                
            }
        }
        
        return returnForec
    }
    
    func updateWeatherLbls(observ: observasion?, forecast: [foreCast?]?) {
        if let observ = observ, let forecast = forecast {
            self.windDirectionLbl.text = self.requestAndPraser.windDirection(direction: observ.windDerction)
            if(observ.windDerction == "Logn"){
                self.windSpeedLbl.text =  "0 m/s"
            } else {
                self.windSpeedLbl.text = observ.windSpeed + " m/s"
            }
            self.heatLbl.text = observ.temperature.replacingOccurrences(of: ",", with: ".") + "°C"
            self.weatherDescriptionLbl.text = self.requestAndPraser.descriptionToIcon(description: observ.weatherDescription)
        } else if let observ = observ {
            //TODO: SHOW SOME ERROR ON FORECAST
            self.windDirectionLbl.text = self.requestAndPraser.windDirection(direction: observ.windDerction)
            if(observ.windDerction == "Logn"){
                self.windSpeedLbl.text =  "0 m/s"
            } else {
                self.windSpeedLbl.text = observ.windSpeed + " m/s"
            }
            self.heatLbl.text = observ.temperature.replacingOccurrences(of: ",", with: ".") + "°C"
            self.weatherDescriptionLbl.text = self.requestAndPraser.descriptionToIcon(description: observ.weatherDescription)
        } else if let forecast = forecast {
            //TODO: SHOW SOME ERROR ON OBSERV 
            
        } else {
            //TODO: SHOW SOME ERROR
        }
      
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

