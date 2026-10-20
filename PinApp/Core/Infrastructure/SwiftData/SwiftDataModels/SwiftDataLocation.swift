//
//  SwiftDataLocation.swift
//  PinApp
//
//  Created by I_IvanM on 03.08.2026.
//

import Foundation
import SwiftData

@Model
final class SwiftDataLocation {

    var id: UUID
    var title: String
    var coordinate: Coordinate
    
    var type: LocationTypeSelection
    var typeData: Data?
    
    var note: String?
    var tags: [String]?
    var photoIDs: [UUID]?
    
    var countryID: String
    var date: Date
    var color: String
    var pinCount: Int
    
    

    
    init(
        id: UUID,
        title: String = "New pin",
        coordinate: Coordinate,
        
        type: LocationTypeSelection,
        typeData: Data?,
        
        note: String? = nil,
        tags: [String]? = [],
        photoIDs: [UUID]? = [],
        
        countryID: String,
        date: Date,
        color: String,
        pinCount: Int,
        
    ) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
        
        self.type = type
        self.typeData = typeData
        
        self.note = note
        self.tags = tags
        self.photoIDs = photoIDs
        
        self.countryID = countryID
        self.date = date
        self.color = color
        self.pinCount = pinCount
    }
}
