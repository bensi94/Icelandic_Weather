//
//  XML_Praser.swift
//  Veður
//
//  Created by Benedikt Óskarsson on 03/10/2017.
//  Copyright © 2017 Benzi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyXMLParser

class WeatherRequestAndPraser {
    
    func getObservasion(stationID: Int, completion: @escaping (_ inner: () throws -> observasion) -> ()){
        var returnObser = observasion(time: "", windSpeed: "", windDerction: "", temperature: "", weatherDescription: "", downfallPerHour: "")
        let request = Alamofire.request("http://xmlweather.vedur.is/?op_w=xml&type=obs&lang=is&view=xml&ids=" + String(stationID))
        request.responseData { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    let xml = XML.parse(data)
                    returnObser.time ?= xml["observations", "station", "time"].text
                    returnObser.windSpeed ?= xml["observations", "station", "F"].text
                    returnObser.windDerction ?= xml["observations", "station", "D"].text
                    returnObser.temperature ?= xml["observations", "station", "T"].text
                    returnObser.weatherDescription ?= xml["observations", "station", "W"].text
                    returnObser.downfallPerHour ?= xml["observations", "station", "R"].text
                    completion({ return returnObser })
                    
                }
            case .failure:
                completion({return returnObser})

            }
            
        }
    }
    
    func getForecast(stationID: Int, completion: @escaping (_ inner: () throws -> [foreCast?]) -> ()){
        var foreCastArray = [foreCast?]()
        let request = Alamofire.request("http://xmlweather.vedur.is/?op_w=xml&type=forec&lang=is&view=xml&ids=" + String(stationID))
        request.responseData { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    let xml = XML.parse(data)
                    for foreCastXml in xml["forecasts", "station", "forecast"] {
                        var currentForeCast = foreCast(time: "", windSpeed: "", windDerction: "", temperature: "", weatherDescription: "", dummyCell: false)
                        currentForeCast.time ?= foreCastXml["ftime"].text
                        currentForeCast.windSpeed ?= foreCastXml["F"].text
                        currentForeCast.windDerction ?= foreCastXml["D"].text
                        currentForeCast.temperature ?= foreCastXml["T"].text
                        currentForeCast.weatherDescription ?= foreCastXml["W"].text
                        foreCastArray.append(currentForeCast)
                    }
                    completion({ return foreCastArray })
                    
                }
            case .failure:
                completion({return foreCastArray})
                
            }
            
        }
    }
    
}
