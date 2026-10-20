//
//  Photo.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

struct Photo: Codable {
    let photoID: UUID
    var localIdentifier: String
    var capturedAt: Date?
    var coordinate: Coordinate?
}
