//
//  Location.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

struct Location {
    let id: UUID
    var title: String
    var coordinate: Coordinate
    
    var type: LocationType
    
    var note: String?
    var tags: [String]?
    var photoIDs: [UUID]?
    
    var countryID: String
    var date: Date
    var color: String
    var pinCount: Int
    
}
