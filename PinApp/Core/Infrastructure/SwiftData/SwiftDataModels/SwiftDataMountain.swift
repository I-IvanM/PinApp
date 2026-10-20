//
//  SwiftDataMountain.swift
//  PinApp
//
//  Created by I_IvanM on 03.08.2026.
//

import Foundation
import SwiftData

@Model
final class SwiftDataMountain {
    
    var mountainName: String
    var height: Double? // in meeter
    var mountainCoordinate: Coordinate
    var mountainPinCount: Int
    
    init (
        mountainName: String,
        height: Double?, // in meeter
        mountainCoordinate: Coordinate,
        mountainPinCount: Int
    ) {
        self.mountainName = mountainName
        self.height = height
        self.mountainCoordinate = mountainCoordinate
        self.mountainPinCount = mountainPinCount
    }
}
