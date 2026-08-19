//
//  PhotoRepository.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation

protocol PhotoRepository {
    
    func fetchAll()throws -> [Photo]

    func fetch(photoID: UUID)throws -> Photo?

    func save(_ photo: Photo)throws

    func delete(_ photoID: UUID)throws
}
