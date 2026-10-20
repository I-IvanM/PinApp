//
//  SwiftDataPhotoRepository.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftData

final class SwiftDataPhotoRepository: PhotoRepository {
    
    private let context: ModelContext
    init(context: ModelContext) {self.context = context}
    
    func fetchAll()throws -> [Photo]{
        let descriptor = FetchDescriptor<SwiftDataPhoto>()
        let swiftDataPhotos = try context.fetch(descriptor)
        return swiftDataPhotos.map { swiftDataPhoto in makePhoto(from: swiftDataPhoto)}
    }

    func fetch(photoID: UUID)throws -> Photo?{
        let descriptor = FetchDescriptor<SwiftDataPhoto>(
                predicate: #Predicate {
                    $0.photoID == photoID
                }
            )
        
        guard let swiftDataPhoto = try context.fetch(descriptor).first else {
            return nil
        }
        
        return makePhoto(from: swiftDataPhoto)
    }

    func save(_ photo: Photo) throws {

        let newPhoto = makeSwiftDataPhoto(from: photo)

        let descriptor = FetchDescriptor<SwiftDataPhoto>(
            predicate: #Predicate {
                $0.photoID == photo.photoID
            }
        )

        if let existingPhoto = try context.fetch(descriptor).first {

            existingPhoto.localIdentifier = newPhoto.localIdentifier
            existingPhoto.capturedAt = newPhoto.capturedAt
            existingPhoto.coordinate = newPhoto.coordinate

        } else {

            context.insert(newPhoto)
        }

        try context.save()
    }

    func delete(_ photoID: UUID)throws{
        let descriptor = FetchDescriptor<SwiftDataPhoto>(
                predicate: #Predicate {
                    $0.photoID == photoID
                }
            )
        
        guard let swiftDataPhoto = try context.fetch(descriptor).first else {
            return
        }
        
        context.delete(swiftDataPhoto)
        
        try context.save()
    }
    
    // MARK: Сonverters Model <-> SwiftDataModel – Private
    
    private func makeSwiftDataPhoto(from photo: Photo) -> SwiftDataPhoto {
        let swiftDataPhoto = SwiftDataPhoto(
            photoID: photo.photoID,
            localIdentifier: photo.localIdentifier,
            capturedAt: photo.capturedAt,
            coordinate: photo.coordinate,
            )
        return swiftDataPhoto
    }
    
    private func makePhoto(from swiftDataPhoto: SwiftDataPhoto) -> Photo {
        let photo = Photo(
            photoID: swiftDataPhoto.photoID,
            localIdentifier: swiftDataPhoto.localIdentifier,
            capturedAt: swiftDataPhoto.capturedAt,
            coordinate: swiftDataPhoto.coordinate,
        )
        return photo
    }
}
