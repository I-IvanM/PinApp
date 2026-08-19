//
//  CityRepository.swift
//  PinApp
//
//  Created by I_IvanM on 31.07.2026.
//

import Foundation

protocol CityRepository {
    
    func fetchAll()throws -> [City]

    func fetch(cityCenterCoordinate: Coordinate)throws -> City?

    func save(_ city: City)throws

    func delete(_ cityCenterCoordinate: Coordinate)throws

}
