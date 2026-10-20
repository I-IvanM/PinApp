//
//  Coordinate.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

struct Coordinate: Codable, Sendable, Hashable {
    var latitude: Double
    var longitude: Double
    var altitude: Double?
    
}
