//
//  LocationRepository.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

protocol LocationRepository {

    func fetchAll()throws -> [Location]

    func fetch(id: UUID)throws -> Location?

    func save(_ location: Location)throws

    func delete(id: UUID)throws

}
