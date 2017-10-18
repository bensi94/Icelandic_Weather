//
//  SingleFCCell.swift
//  Veður
//
//  Created by Benedikt Óskarsson on 18/10/2017.
//  Copyright © 2017 Benzi. All rights reserved.
//

import UIKit

class SingleFCCell: UICollectionViewCell {
    
    @IBOutlet weak var fTimeLbl: UILabel!
    @IBOutlet weak var fWindLbl: UILabel!
    @IBOutlet weak var fWeatherDescription: UILabel!
    @IBOutlet weak var fTempLbl: UILabel!
    
    func configureCell(forecast: foreCast){
        let forGettingIcon = WeatherRequestAndPraser()
        if !forecast.time.isEmpty {
            let time = forecast.time
            let indexStartOfText = time.index(time.startIndex, offsetBy: 11)
            let indexEndOfText = time.index(time.endIndex, offsetBy: -3)
            fTimeLbl.text = String(time[indexStartOfText..<indexEndOfText])
        }
        fWindLbl.text = forecast.windDerction + " " + forecast.windSpeed + " m/s"
        fWeatherDescription.text = forGettingIcon.descriptionToIcon(description: forecast.weatherDescription)
        fTempLbl.text = forecast.temperature.replacingOccurrences(of: ",", with: ".") + "°C"
    }
    
}

