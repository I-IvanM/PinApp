//
//  SwiftDataCity.swift
//  PinApp
//
//  Created by I_IvanM on 03.08.2026.
//

import Foundation
import SwiftData

@Model
final class SwiftDataCity {
    
    var cityName: String
    var cityCenterCoordinate: Coordinate
    var cityPinCount: Int
    
    init(
        
        cityName: String,
        cityCenterCoordinate: Coordinate,
        cityPinCount: Int,
        
    ){
        
        self.cityName = cityName
        self.cityCenterCoordinate = cityCenterCoordinate
        self.cityPinCount = cityPinCount
    }
}
