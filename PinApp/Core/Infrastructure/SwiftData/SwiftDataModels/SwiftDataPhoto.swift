//
//  SwiftDataPhoto.swift
//  PinApp
//
//  Created by I_IvanM on 03.08.2026.
//

import Foundation
import SwiftData

@Model
final class SwiftDataPhoto {
    
    var photoID: UUID
    var localIdentifier: String
    var capturedAt: Date?
    var coordinate: Coordinate?
    
    init (
    photoID: UUID,
    localIdentifier: String,
    capturedAt: Date? = nil,
    coordinate: Coordinate? = nil
    ) {
        self.photoID = photoID
        self.localIdentifier = localIdentifier
        self.capturedAt = capturedAt
        self.coordinate = coordinate
    }
}
