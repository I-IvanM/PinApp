//
//  SwiftDataMountainRepository.swift
//  PinApp
//
//  Created by I_IvanM on 31.07.2026.
//

import Foundation
import SwiftData

final class SwiftDataMountainRepository: MountainRepository {
    
    private let context: ModelContext
    init(context: ModelContext) {self.context = context}
    
    func fetchAll()throws -> [Mountain]{
        let descriptor = FetchDescriptor<SwiftDataMountain>()
        let swiftDataMountains = try context.fetch(descriptor)
        return swiftDataMountains.map { swiftDataMountain in makeMountain(from: swiftDataMountain)}
    }

    func fetch(mountainCoordinate: Coordinate)throws -> Mountain?{
        let descriptor = FetchDescriptor<SwiftDataMountain>(
                predicate: #Predicate {
                    $0.mountainCoordinate.latitude == mountainCoordinate.latitude && $0.mountainCoordinate.longitude == mountainCoordinate.longitude
                }
            )
        
        guard let swiftDataMountain = try context.fetch(descriptor).first else {
            return nil
        }
        
        return makeMountain(from: swiftDataMountain)
    }

    func save(_ mountain: Mountain) throws {

        let newMountain = makeSwiftDataMountain(from: mountain)
        let latitude = mountain.mountainCoordinate.latitude
        let longitude = mountain.mountainCoordinate.longitude

        let descriptor = FetchDescriptor<SwiftDataMountain>(
            predicate: #Predicate {
                $0.mountainCoordinate.latitude == latitude &&
                $0.mountainCoordinate.longitude == longitude
            }
        )

        if let existingMountain = try context.fetch(descriptor).first {

            existingMountain.mountainName = newMountain.mountainName
            existingMountain.height = newMountain.height
            existingMountain.mountainPinCount = newMountain.mountainPinCount

        } else {

            context.insert(newMountain)
        }

        try context.save()
    }

    func delete(_ mountainCoordinate: Coordinate)throws{
        let descriptor = FetchDescriptor<SwiftDataMountain>(
            predicate: #Predicate {
                $0.mountainCoordinate.latitude == mountainCoordinate.latitude && $0.mountainCoordinate.longitude == mountainCoordinate.longitude
            }
        )
        
        guard let swiftDataMountain = try context.fetch(descriptor).first else {
            return
        }
        
        context.delete(swiftDataMountain)
        
        try context.save()
    }
    
    
    // MARK: Сonverters Model <-> SwiftDataModel – Private
    
    private func makeSwiftDataMountain(from mountain: Mountain) -> SwiftDataMountain {
        let swiftDataMountain = SwiftDataMountain(
            mountainName: mountain.mountainName,
            height: mountain.height,
            mountainCoordinate: mountain.mountainCoordinate,
            mountainPinCount: mountain.mountainPinCount
        )
        return swiftDataMountain
    }
    
    private func makeMountain(from swiftDataMountain: SwiftDataMountain) -> Mountain {
        let mountain = Mountain(
            mountainName: swiftDataMountain.mountainName,
            height: swiftDataMountain.height,
            mountainCoordinate: swiftDataMountain.mountainCoordinate,
            mountainPinCount: swiftDataMountain.mountainPinCount
        )
        return mountain
    }
}
