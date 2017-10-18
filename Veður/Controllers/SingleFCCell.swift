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
        fTimeLbl.text = forecast.time
        fWindLbl.text = forecast.windSpeed
        fWeatherDescription.text = forecast.weatherDescription
        fTempLbl.text = forecast.temperature
    }
    
}

