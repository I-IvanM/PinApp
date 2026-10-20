//
//  SwiftDataLocationRepository.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftData

final class SwiftDataLocationRepository: LocationRepository {
    
    private let context: ModelContext
    init(context: ModelContext) {self.context = context}
    
    func fetchAll() throws -> [Location] {
        let descriptor = FetchDescriptor<SwiftDataLocation>()
        let swiftDataLocations = try context.fetch(descriptor)
        return swiftDataLocations.map { swiftDataLocation in makeLocation(from: swiftDataLocation)}
    }

    func fetch(id: UUID) throws -> Location? {
        
        let descriptor = FetchDescriptor<SwiftDataLocation>(
                predicate: #Predicate {
                    $0.id == id
                }
            )
        
        guard let swiftDataLocation = try context.fetch(descriptor).first else {
            return nil
        }
        
        return makeLocation(from: swiftDataLocation)
    }

    func save(_ location: Location) throws {

        let newLocation = makeSwiftDataLocation(from: location)
        let id = location.id

        let descriptor = FetchDescriptor<SwiftDataLocation>(
            predicate: #Predicate {
                $0.id == id
            }
        )

        if let existingLocation = try context.fetch(descriptor).first {

            existingLocation.title = newLocation.title
            existingLocation.coordinate = newLocation.coordinate

            existingLocation.type = newLocation.type
            existingLocation.typeData = newLocation.typeData

            existingLocation.note = newLocation.note
            existingLocation.tags = newLocation.tags
            existingLocation.photoIDs = newLocation.photoIDs

            existingLocation.countryID = newLocation.countryID
            existingLocation.date = newLocation.date
            existingLocation.color = newLocation.color
            existingLocation.pinCount = newLocation.pinCount


        } else {

            context.insert(newLocation)
        }

        try context.save()
    }

    func delete(id: UUID) throws {
        
        let descriptor = FetchDescriptor<SwiftDataLocation>(
            predicate: #Predicate {
                $0.id == id
            }
        )
        
        guard let swiftDataLocation = try context.fetch(descriptor).first else {
            return
        }
        
        context.delete(swiftDataLocation)
        
        try context.save()
    }
    
    
    
    // MARK: Сonverters Model <-> SwiftDataModel – Private
    
    private func makeSwiftDataLocation(from location: Location) -> SwiftDataLocation {
        
        let type: LocationTypeSelection
        
        switch location.type {
        case .point:
            type = .point
            
        case .city:
            type = .city
            
        case .mountain:
            type = .mountain
        }
        
        let typeData = try? JSONEncoder().encode(location.type)
        
        return SwiftDataLocation(
            id: location.id,
            title: location.title,
            coordinate: location.coordinate,
            
            type: type,
            typeData: typeData,
            
            note: location.note,
            tags: location.tags,
            photoIDs: location.photoIDs,
            
            countryID: location.countryID,
            date: location.date,
            color: location.color,
            pinCount: location.pinCount,
        )
    }

    private func makeLocation(from swiftDataLocation: SwiftDataLocation) -> Location {
        
        guard let typeData = swiftDataLocation.typeData,
              let type = try? JSONDecoder().decode(
                  LocationType.self,
                  from: typeData
              )
        else {
            fatalError("Invalid or missing LocationType data")
        }
        
        return Location(
            id: swiftDataLocation.id,
            title: swiftDataLocation.title,
            coordinate: swiftDataLocation.coordinate,
            
            type: type,
            
            note: swiftDataLocation.note,
            tags: swiftDataLocation.tags,
            photoIDs: swiftDataLocation.photoIDs,
            
            countryID: swiftDataLocation.countryID,
            date: swiftDataLocation.date,
            color: swiftDataLocation.color,
            pinCount: swiftDataLocation.pinCount,
        )
    }

}
