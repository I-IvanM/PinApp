//
//  SwiftDataCityRepository.swift
//  PinApp
//
//  Created by I_IvanM on 31.07.2026.
//

import Foundation
import SwiftData

final class SwiftDataCityRepository: CityRepository {
    
    private let context: ModelContext
    init(context: ModelContext) {self.context = context}
    
    func fetchAll() throws -> [City]{
        let descriptor = FetchDescriptor<SwiftDataCity>()
        let swiftDataCities = try context.fetch(descriptor)
        return swiftDataCities.map { swiftDataCity in makeCity(from: swiftDataCity)}
    }

    func fetch(cityCenterCoordinate: Coordinate) throws -> City?{
        
        let descriptor = FetchDescriptor<SwiftDataCity>(
                predicate: #Predicate {
                    $0.cityCenterCoordinate.latitude == cityCenterCoordinate.latitude && $0.cityCenterCoordinate.longitude == cityCenterCoordinate.longitude
                }
            )
        
        guard let swiftDataCity = try context.fetch(descriptor).first else {
            return nil
        }
        
        return makeCity(from: swiftDataCity)
    }

    func save(_ city: City) throws {

        let newCity = makeSwiftDataCity(from: city)
        let latitude = city.cityCenterCoordinate.latitude
        let longitude = city.cityCenterCoordinate.longitude

        let descriptor = FetchDescriptor<SwiftDataCity>(
            predicate: #Predicate {
                $0.cityCenterCoordinate.latitude == latitude &&
                $0.cityCenterCoordinate.longitude == longitude
            }
        )

        if let existingCity = try context.fetch(descriptor).first {

            existingCity.cityName = newCity.cityName
            existingCity.cityPinCount = newCity.cityPinCount

        } else {

            context.insert(newCity)
        }

        try context.save()
    }

    func delete(_ cityCenterCoordinate: Coordinate)throws{
        let descriptor = FetchDescriptor<SwiftDataCity>(
            predicate: #Predicate {
                $0.cityCenterCoordinate.latitude == cityCenterCoordinate.latitude && $0.cityCenterCoordinate.longitude == cityCenterCoordinate.longitude
            }
        )
        
        guard let swiftDataCity = try context.fetch(descriptor).first else {
            return
        }
        
        context.delete(swiftDataCity)
        
        try context.save()
    }
    
    // MARK: Сonverters Model <-> SwiftDataModel – Private
    
    private func makeSwiftDataCity(from city: City) -> SwiftDataCity {
        
        let swiftDataCity = SwiftDataCity(
            cityName: city.cityName,
            cityCenterCoordinate: city.cityCenterCoordinate,
            cityPinCount: city.cityPinCount
        )
        
        return swiftDataCity
        
    }
    
    private func makeCity(from swiftDataCity: SwiftDataCity) -> City {
        
        let city = City(
            cityName: swiftDataCity.cityName,
            cityCenterCoordinate: swiftDataCity.cityCenterCoordinate,
            cityPinCount: swiftDataCity.cityPinCount
            )
        return city
    }
    
}
