//
//  AllValues.swift
//  PinApp
//
//  Created by I_IvanM on 14.08.2026.
//

import Foundation

struct AllValues {
    var id: UUID?
    var title: String?
    var coordinate: Coordinate?
    
    var type: LocationTypeSelection?
    
    var note: String?
    var tags: [String]?
    var photoIDs: [UUID]?
    
    var countryID: String?
    var countryName: String?
    var countryPinCount: Int?
    
    var date: Date?
    var color: String?
    var pinCount: Int?
    
    var cityName: String?
    var cityCenterCoordinate: Coordinate?
    var cityPinCount: Int?
    var address: String?
    
    var mountainName: String?
    var height: Double? // in meeter?
    var mountainCoordinate: Coordinate?
    var mountainPinCount: Int?
    var achievedHeight: Double?
}
