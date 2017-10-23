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
import GooglePlaces

extension Notification.Name {
    static let reload = Notification.Name("reload")
}

class ViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    let manager = CLLocationManager()
    var appServer = AppServer()
    var requestAndPraser = WeatherRequestAndPraser()
    var valueConverter = ValueConverter()
    var closestStation: Station?
    var foreCasts = [foreCast?]()
    var placesClient: GMSPlacesClient!
    var needsUpdate: Bool = true
    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var townLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var windDirectionLbl: UILabel!
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var heatLbl: UILabel!
    @IBOutlet weak var stasionLbl: UILabel!
    @IBOutlet weak var weatherDescriptionLbl: UILabel!
    @IBOutlet weak var foreCastCollectionView: UICollectionView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notfiCenter = NotificationCenter.default
        notfiCenter.addObserver(self, selector: #selector(reloadCollectionView), name: .reload, object: nil)
        appServer.loadStations()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
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
            requestAndPraser.getObservasion(stationID: currentStation.stationNumber) { (inner: () throws -> observasion) -> Void in
                do {
                    let ObsrvResult = try inner()
                    self.requestAndPraser.getForecast(stationID: currentStation.stationNumber) { (inner: () throws -> [foreCast?]) -> Void in
                        do {
                            let foreCastResult = try inner()
                            let relevantForecast = self.appServer.relevantForecast(foreCasts: foreCastResult)
                            self.updateWeatherLbls(observ: ObsrvResult, forecast: relevantForecast)
                            self.updateForcastDate()
                            if self.foreCasts.count != foreCastResult.count{
                                self.foreCasts = relevantForecast
                                self.foreCastCollectionView.reloadData()
                            }
                        } catch _ {
                            
                        }
                    }
                    
                } catch _ {
                    
                }
            }
            
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
                    self.areaLbl.text = thoroughfare
                } else {
                    self.areaLbl.text = placemark.name
                }
                
                if let locality = placemark.locality{
                    self.townLbl.text = locality
                } else {
                    self.townLbl.text = placemark.country
                }
            }
            
        }
        
        if needsUpdate {
            self.loadFirstPhotoForPlace(placeID: "ChIJUZKzlO4N1UgRC6K9h87sKwU")
            needsUpdate = false
        }
    }
    
    func updateWeatherLbls(observ: observasion?, forecast: [foreCast?]?) {
        //In here we use closest forecast to back up if we don't get the information we need from observasions
        if let observ = observ, let forecast = forecast {
            if observ.windDerction.isEmpty{
                if forecast.indices.contains(0){
                    let closestForecast = forecast[0]!
                    self.windDirectionLbl.text = self.valueConverter.windDirection(direction: closestForecast.windDerction)
                }
            } else {
                self.windDirectionLbl.text = self.valueConverter.windDirection(direction: observ.windDerction)
            }
            if(observ.windDerction == "Logn"){
                self.windSpeedLbl.text =  "0 m/s"
            } else {
                
                if observ.windSpeed.isEmpty{
                    if forecast.indices.contains(0){
                        let closestForecast = forecast[0]!
                        self.windSpeedLbl.text = closestForecast.windSpeed + " m/s"
                    }
                } else {
                   self.windSpeedLbl.text = observ.windSpeed + " m/s"
                }
                
            }
            if observ.temperature.isEmpty{
                if forecast.indices.contains(0){
                    let closestForecast = forecast[0]!
                    self.heatLbl.text = closestForecast.temperature.replacingOccurrences(of: ",", with: ".") + "°C"
                }
            } else {
                self.heatLbl.text = observ.temperature.replacingOccurrences(of: ",", with: ".") + "°C"
            }
            
            if observ.weatherDescription.isEmpty{
                if forecast.indices.contains(0){
                    let closestForecast = forecast[0]!
                    self.weatherDescriptionLbl.text = self.valueConverter.descriptionToIcon(description: closestForecast.weatherDescription)
                }
            } else {
               self.weatherDescriptionLbl.text = self.valueConverter.descriptionToIcon(description: observ.weatherDescription)
            }
            
            
        } else if let observ = observ {
            //TODO: SHOW SOME ERROR ON FORECAST
            self.windDirectionLbl.text = self.valueConverter.windDirection(direction: observ.windDerction)
            if(observ.windDerction == "Logn"){
                self.windSpeedLbl.text =  "0 m/s"
            } else {
                self.windSpeedLbl.text = observ.windSpeed + " m/s"
            }
            self.heatLbl.text = observ.temperature.replacingOccurrences(of: ",", with: ".") + "°C"
            self.weatherDescriptionLbl.text = self.valueConverter.descriptionToIcon(description: observ.weatherDescription)
        } else if let forecast = forecast {
            //TODO: SHOW SOME ERROR ON OBSERV
            
        } else {
            //TODO: SHOW SOME ERROR
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foreCasts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleFCCell", for: indexPath) as? SingleFCCell {
            if let forecast = foreCasts[indexPath.item]{
                cell.configureCell(forecast: forecast)
            }
            return cell
        } else {
            return SingleFCCell()
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateForcastDate()
    }
    
    func updateForcastDate()  {
        var closestCell: UICollectionViewCell = UICollectionViewCell()
        if foreCastCollectionView.visibleCells.indices.contains(0){
            closestCell = foreCastCollectionView.visibleCells[0]
            for cell in foreCastCollectionView.visibleCells {
                if abs(closestCell.frame.minX - dayLbl.frame.minX) <  abs(cell.frame.minX - dayLbl.frame.minX){
                    closestCell = cell
                }
            }
            let indexItem: Int? = self.foreCastCollectionView.indexPath(for: closestCell)?.item
            if let item = indexItem {
                if(item == 0 || item == 1){
                    if let time = foreCasts[item]?.time{
                        let timeStamp: TimeInterval = self.appServer.getTimeStamp(forecastTime: time)
                        self.dayLbl.text = valueConverter.getDay(timeStamp: timeStamp)
                        self.dateLbl.text = valueConverter.getDate(timeStamp: timeStamp)
                    }
                } else {
                    if let time = foreCasts[item-2]?.time{
                        let timeStamp: TimeInterval = self.appServer.getTimeStamp(forecastTime: time)
                        self.dayLbl.text = valueConverter.getDay(timeStamp: timeStamp)
                        self.dateLbl.text = valueConverter.getDate(timeStamp: timeStamp)
                    }
                }
            }
        }
    }
    
    @objc func reloadCollectionView(_ notification: Notification) {
        foreCastCollectionView.reloadData()
        foreCastCollectionView.setContentOffset(.zero, animated: false)
        self.updateForcastDate()
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.bgImg.image = photo
                print(photoMetadata.attributions)
            }
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

