//
//  SwiftDataCountry.swift
//  PinApp
//
//  Created by I_IvanM on 03.08.2026.
//

import Foundation
import SwiftData

@Model
final class SwiftDataCountry {
    
    @Attribute(.unique)
    var countryID: String
    
    var countryName: String
    var countryPinCount: Int
    var continent: String
    
    init(
        countryID: String,
        countryName: String,
        countryPinCount: Int = 0,
        continent: String
    ){
        self.countryID = countryID
        self.countryName = countryName
        self.countryPinCount = countryPinCount
        self.continent = continent
    }
}
