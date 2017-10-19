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

struct observasion {
    var time: String
    var windSpeed: String
    var windDerction: String
    var temperature: String
    var weatherDescription: String
    var downfallPerHour: String
}

struct foreCast {
    var time: String
    var windSpeed: String
    var windDerction: String
    var temperature: String
    var weatherDescription: String
    var dummyCell: Bool = false
}

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
    
    func descriptionToIcon(description: String) -> String {
        var iconUnicodeValue = ""
        switch description {
        case "Heiðskírt": iconUnicodeValue = "\u{f00d}"
        case "Léttskýjað": iconUnicodeValue = "\u{f002}"
        case "Skýjað": iconUnicodeValue = "\u{f041}"
        case "Alskýjað": iconUnicodeValue = "\u{f013}"
        case "Lítils háttar rigning": iconUnicodeValue = "\u{f01c}"
        case "Rigning": iconUnicodeValue = "\u{f01a}"
        case "Lítils háttar slydda": iconUnicodeValue = "\u{f0b5}"
        case "Slydda": iconUnicodeValue = "\u{f017}"
        case "Lítils háttar snjókoma": iconUnicodeValue = "\u{f065}"
        case "Snjókoma": iconUnicodeValue = "\u{f064}"
        case "Skúrir": iconUnicodeValue = "\u{f01a}"
        case "Slydduél": iconUnicodeValue = "\u{f0b5}"
        case "Snjóél": iconUnicodeValue = "\u{f015}"
        case "Skýstrókar": iconUnicodeValue = "\u{f056}"
        case "Moldrok": iconUnicodeValue = "\u{f082}"
        case "Skafrenningur": iconUnicodeValue = "\u{f082}"
        case "Þoka": iconUnicodeValue = "\u{f014}"
        case "Lítils háttar súld": iconUnicodeValue = "\u{f01c}"
        case "Súld": iconUnicodeValue = "\u{f01a}"
        case "Frostrigning": iconUnicodeValue = "\u{f017}"
        case "Hagl": iconUnicodeValue = "\u{f015}"
        case "Lítils háttar þrumuveður": iconUnicodeValue = "\u{f01d}"
        case "Þrumuveður": iconUnicodeValue = "\u{f01e}"
        default:
            iconUnicodeValue = ""
        }
        return iconUnicodeValue
    }
    
    func windDirection(direction: String) -> String {
        switch direction {
        case "A": return "Austan"
        case "V": return "Vestan"
        case "N": return "Norðan"
        case "S": return "Sunnan"
        default:
            return direction
        }
    }
    
    
}
