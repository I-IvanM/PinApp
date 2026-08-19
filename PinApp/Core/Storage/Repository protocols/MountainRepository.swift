//
//  MountainRepository.swift
//  PinApp
//
//  Created by I_IvanM on 31.07.2026.
//

import Foundation

protocol MountainRepository {
    
    func fetchAll()throws -> [Mountain]

    func fetch(mountainCoordinate: Coordinate)throws -> Mountain?

    func save(_ mountain: Mountain)throws

    func delete(_ mountainCoordinate: Coordinate)throws

}
