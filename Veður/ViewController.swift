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
     var stations: [Stasion] = []
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var closestStasion: Stasion?
        var smallestDistance: CLLocationDistance?
        
        if let userLocation = manager.location {
            for station in stations {
                let location = CLLocation(latitude: station.latitude, longitude: station.longitude)
                let distance = userLocation.distance(from: location)
                if smallestDistance == nil || distance < smallestDistance! {
                    smallestDistance = distance
                    closestStasion = station
                }
            }
        }
        
        let urlString = "http://apis.is/weather/observations/is?stations=" + (closestStasion?.stasionNumber.description)!
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error)
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    
                    print(parsedData)

                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        if let path = Bundle.main.path(forResource: "Stasions", ofType: "txt"){
            do
            {
                
                let contents = try String(contentsOfFile: path)
                let lines = contents.components(separatedBy: "\n")
                
                for line in lines {
                    let prashe = line.components(separatedBy: "; ")
                    
                    if line != "" {
                        let station = Stasion()
                        station.id = Int(prashe[0])!
                        station.name = prashe[1]
                        station.stasionNumber = Int(prashe[2])!
                        station.latitude = Double(prashe[3])!
                        station.longitude = Double(prashe[4])!
                        station.area = prashe[5]
                        stations.append(station)
                    }
                    
                }
                
            }
            catch
            {
                // contents could not be loaded
            }
        }
    
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

