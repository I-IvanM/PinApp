//
//  ReverseGeocodingService.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import CoreLocation
import MapKit

final class ReverseGeocodingService {

    private let networkMonitor: NetworkMonitor
    private let countrySearch: CountrySearch

    init(
        networkMonitor: NetworkMonitor,
        countrySearch: CountrySearch
    ) {
        self.networkMonitor = networkMonitor
        self.countrySearch = countrySearch
    }

    // MARK: - Country

    func countryID(
        for coordinate: Coordinate
    ) -> String? {
        countrySearch.search(
            coordinate: coordinate
        )
    }

    // MARK: - Full Reverse Geocoding

    func reverseGeocode(
        coordinate: Coordinate
    ) async -> (
        countryID: String?,
        title: String?,
        cityName: String?,
        address: String?
    ) {

        let countryID = countryID(
            for: coordinate
        )

        guard networkMonitor.isConnected else {
            return (
                countryID: countryID,
                title: nil,
                cityName: nil,
                address: nil
            )
        }

        let appleResult = await reverseGeocodeUsingApple(
            coordinate: coordinate
        )

        return (
            countryID: countryID,
            title: appleResult.title,
            cityName: appleResult.cityName,
            address: appleResult.address
        )
    }

    // MARK: - Apple

    private func reverseGeocodeUsingApple(
        coordinate: Coordinate
    ) async -> (
        title: String?,
        cityName: String?,
        address: String?
    ) {

        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        guard let request = MKReverseGeocodingRequest(
            location: location
        ) else {
            print("Failed to create reverse geocoding request.")

            return (
                title: nil,
                cityName: nil,
                address: nil
            )
        }

        do {
            let mapItems = try await request.mapItems

            guard let mapItem = mapItems.first else {
                print("No reverse geocoding results.")

                return (
                    title: nil,
                    cityName: nil,
                    address: nil
                )
            }

            let addressRepresentations = mapItem.addressRepresentations

            let title = mapItem.name
            let cityName = addressRepresentations?.cityName
            let address = mapItem.address?.shortAddress

            /*
            print("========== Reverse Geocoding ==========")
            print("Title: \(String(describing: title))")
            print("City name: \(String(describing: cityName))")
            print("Address: \(String(describing: address))")
            print("=======================================")
             */

            return (
                title: title,
                cityName: cityName,
                address: address
            )

        } catch {
            print("Reverse geocoding failed: \(error)")

            return (
                title: nil,
                cityName: nil,
                address: nil
            )
        }
    }
}
