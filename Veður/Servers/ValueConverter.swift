//
//  ValueConverter.swift
//  Veður
//
//  Created by Benedikt Óskarsson on 20/10/2017.
//  Copyright © 2017 Benzi. All rights reserved.
//

import Foundation

class ValueConverter {
    
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
    
    func getDay(timeStamp: TimeInterval) -> String {
        let calander = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let date = NSDate(timeIntervalSince1970: timeStamp)
        switch  calander.component(.weekday, from: date as Date) {
        case 1: return "Sunnudagur"
        case 2: return "Mánudagur"
        case 3: return "Þriðjudagur"
        case 4: return "Miðvikudagur"
        case 5: return "Fimmtudagur"
        case 6: return "Föstudagur"
        case 7: return "Laugardagur"
        default:
            return ""
        }
    }
    
    func getDate(timeStamp: TimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM" //Specify your format that you want
        let strDate = dateFormatter.string(from: date as Date)
        return  strDate.replacingOccurrences(of: "-", with: "/")
    }
}
