//
//  AppServer.swift
//  Veður
//
//  Created by Benedikt Óskarsson on 03/10/2017.
//  Copyright © 2017 Benzi. All rights reserved.
//

import Foundation

class AppServer {
    
    private var stations: [Station] = []
    
    func loadStations()  {
 
        if let path = Bundle.main.path(forResource: "stations", ofType: "txt"){
            do
            {
                
                let contents = try String(contentsOfFile: path)
                let lines = contents.components(separatedBy: "\n")
                
                for line in lines {
                    let prashe = line.components(separatedBy: "; ")
                    
                    if line != "" {
                        let station = Station()
                        station.id = Int(prashe[0])!
                        station.name = prashe[1]
                        station.stationNumber = Int(prashe[2])!
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
    }
    
    func getStations() -> [Station] {
        return stations
    }
    
}
