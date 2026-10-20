//
//  FromPhotoCoordinatesImportService.swift
//  PinApp
//
//  Created by I_IvanM on 28.08.2026.
//

import Foundation
import Photos

@MainActor
final class FromPhotoCoordinatesImportService {

    private let photoLibraryManager: PhotoLibraryManager
    private let locationService: LocationService
    private let creationService: CreationService
    private let reverseGeocodingService: ReverseGeocodingService

    private let minimumInterval: TimeInterval = 60
    private let minimumDistanceAngle = 0.0007848

    // MARK: - Init

    init(
        photoLibraryManager: PhotoLibraryManager,
        locationService: LocationService,
        creationService: CreationService,
        reverseGeocodingService: ReverseGeocodingService
    ) {
        self.photoLibraryManager = photoLibraryManager
        self.locationService = locationService
        self.creationService = creationService
        self.reverseGeocodingService = reverseGeocodingService
    }

    // MARK: - Import

    func importPhotos(
        onProgress: @escaping (PhotoImportProgress) -> Void
    ) async throws {


        let authorized = await photoLibraryManager.requestFullAccess()

        guard authorized else {
            return
        }


        var locations = try locationService.fetchAll()

        let assets = photoLibraryManager.fetchPhotoAssets()
        let totalCount = assets.count

        var previousPhoto: PhotoMetadata?
        var processedCount = 0
        var createdCount = 0

        sendProgress(
            processedCount: processedCount,
            totalCount: totalCount,
            createdCount: createdCount,
            onProgress: onProgress
        )

        for index in 0..<totalCount {

            let asset = assets.object(at: index)

            guard let metadata = makeMetadata(from: asset) else {

                processedCount += 1

                sendProgress(
                    processedCount: processedCount,
                    totalCount: totalCount,
                    createdCount: createdCount,
                    onProgress: onProgress
                )

                await Task.yield()
                continue
            }

            guard shouldProcess(
                metadata: metadata,
                previousPhoto: previousPhoto
            ) else {

                processedCount += 1

                sendProgress(
                    processedCount: processedCount,
                    totalCount: totalCount,
                    createdCount: createdCount,
                    onProgress: onProgress
                )

                await Task.yield()
                continue
            }

            guard isFarEnoughFromExistingLocations(
                coordinate: metadata.coordinate,
                locations: locations
            ) else {

                processedCount += 1

                sendProgress(
                    processedCount: processedCount,
                    totalCount: totalCount,
                    createdCount: createdCount,
                    onProgress: onProgress
                )

                await Task.yield()
                continue
            }

            previousPhoto = metadata

            let location = try await createLocation(from: metadata)

            locations.append(location)
            createdCount += 1

            processedCount += 1

            sendProgress(
                processedCount: processedCount,
                totalCount: totalCount,
                createdCount: createdCount,
                onProgress: onProgress
            )

            await Task.yield()
        }
    }

    // MARK: - Private

    private func makeMetadata(from asset: PHAsset) -> PhotoMetadata? {
        guard let location = asset.location else {
            return nil
        }

        let coordinate = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude
        )

        return PhotoMetadata(
            coordinate: coordinate,
            date: asset.creationDate,
            title: "Imported from Photos"
        )
    }

    private func shouldProcess(metadata: PhotoMetadata, previousPhoto: PhotoMetadata?) -> Bool {

        guard let previousPhoto else {
            return true
        }

        guard let previousDate = previousPhoto.date,
              let currentDate = metadata.date else {
            return true
        }

        let interval = previousDate.timeIntervalSince(currentDate)

        return interval >= minimumInterval
    }

    private func isFarEnoughFromExistingLocations(
        coordinate: Coordinate,
        locations: [Location]
    ) -> Bool {

        for location in locations {

            let angle = angularDistance(
                from: coordinate,
                to: location.coordinate
            )

            if angle <= minimumDistanceAngle {
                return false
            }
        }

        return true
    }

    private func angularDistance(
        from first: Coordinate,
        to second: Coordinate
    ) -> Double {

        let firstLatitude = first.latitude * .pi / 180
        let firstLongitude = first.longitude * .pi / 180

        let secondLatitude = second.latitude * .pi / 180
        let secondLongitude = second.longitude * .pi / 180

        let value =
            cos(firstLatitude)
            * cos(secondLatitude)
            * cos(firstLongitude - secondLongitude)
            + sin(firstLatitude)
            * sin(secondLatitude)

        let clampedValue = min(
            1,
            max(-1, value)
        )

        return acos(clampedValue)
    }

    private func createLocation(
        from metadata: PhotoMetadata
    ) async throws -> Location {

        let countryID = reverseGeocodingService.countryID(for: metadata.coordinate)

        var allValues = AllValues()

        allValues.coordinate = metadata.coordinate
        allValues.type = .point
        allValues.title = metadata.title ?? "Imported from Photos"
        allValues.date = metadata.date
        allValues.countryID = countryID

        return try await creationService.create(from: allValues)
    }

    private func sendProgress(
        processedCount: Int,
        totalCount: Int,
        createdCount: Int,
        onProgress: @escaping (PhotoImportProgress) -> Void
    ) {
        onProgress(
            PhotoImportProgress(
                processedCount: processedCount,
                totalCount: totalCount,
                createdCount: createdCount
            )
        )
    }
}
