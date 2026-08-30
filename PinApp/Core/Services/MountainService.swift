//
//  MountainServise.swift
//  PinApp
//
//  Created by I_IvanM on 14.08.2026.
//

import Foundation

final class MountainService {

    private let repository: MountainRepository

    init(repository: MountainRepository) {
        self.repository = repository
    }

    func fetchAllMountains() throws -> [Mountain] {
        return try repository.fetchAll()
    }

    func fetchMountain(by mountainCoordinate: Coordinate) throws -> Mountain? {
        return try repository.fetch(
            mountainCoordinate: mountainCoordinate
        )
    }

    func saveMountain(_ mountain: Mountain) throws {
        try repository.save(mountain)
    }

    func deleteMountain(at mountainCoordinate: Coordinate) throws {
        try repository.delete(mountainCoordinate)
    }

    func plusPin(for mountainCoordinate: Coordinate) throws {
        guard let mountain = try repository.fetch(
            mountainCoordinate: mountainCoordinate
        ) else {
            return
        }

        var updatedMountain = mountain
        updatedMountain.mountainPinCount += 1

        try repository.save(updatedMountain)
    }

    func minusPin(for mountainCoordinate: Coordinate) throws {
        guard let mountain = try repository.fetch(
            mountainCoordinate: mountainCoordinate
        ) else {
            return
        }

        var updatedMountain = mountain
        updatedMountain.mountainPinCount = max(
            0,
            updatedMountain.mountainPinCount - 1
        )

        try repository.save(updatedMountain)
    }
}
