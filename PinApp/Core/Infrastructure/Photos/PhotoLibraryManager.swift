//
//  PhotoLibraryManager.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import Photos

final class PhotoLibraryManager {

    func requestFullAccess() async -> Bool {
        let currentStatus = PHPhotoLibrary.authorizationStatus(
            for: .readWrite
        )

        switch currentStatus {
        case .authorized:
            return true

        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(
                for: .readWrite
            )

            return status == .authorized

        case .denied, .restricted, .limited:
            return false

        @unknown default:
            return false
        }
    }

    func fetchPhotoAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()

        options.sortDescriptors = [
            NSSortDescriptor(
                key: "creationDate",
                ascending: false
            )
        ]

        options.predicate = NSPredicate(
            format: "mediaType == %d",
            PHAssetMediaType.image.rawValue
        )

        return PHAsset.fetchAssets(
            with: .image,
            options: options
        )
    }
}
