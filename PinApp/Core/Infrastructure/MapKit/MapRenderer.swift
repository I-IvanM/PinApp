//
//  MapRenderer.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import MapKit

final class MapRenderer: NSObject {

    private let annotationFactory: AnnotationFactory

    private var annotationsByID: [UUID: LocationAnnotation] = [:]

    var onLocationSelected: ((UUID) -> Void)?

    init(annotationFactory: AnnotationFactory = AnnotationFactory()) {
        self.annotationFactory = annotationFactory
    }

    func update(
        locations: [Location],
        on mapView: MKMapView
    ) {
        let locationsByID = Dictionary(
            uniqueKeysWithValues: locations.map {
                ($0.id, $0)
            }
        )

        removeDeletedAnnotations(
            locationsByID: locationsByID,
            from: mapView
        )

        updateExistingAnnotations(
            locationsByID: locationsByID,
            on: mapView
        )

        addNewAnnotations(
            locationsByID: locationsByID,
            to: mapView
        )
    }
    
    func makeView(
        for annotation: MKAnnotation,
        in mapView: MKMapView
    ) -> MKAnnotationView? {
        guard annotation is LocationAnnotation else {
            return nil
        }

        return annotationFactory.makeView(
            for: annotation,
            in: mapView
        )
    }
    
    func handleSelection(
        of annotation: LocationAnnotation
    ) {
        onLocationSelected?(annotation.locationID)
    }


    private func removeDeletedAnnotations(
        locationsByID: [UUID: Location],
        from mapView: MKMapView
    ) {
        let deletedIDs = annotationsByID.keys.filter {
            locationsByID[$0] == nil
        }

        for id in deletedIDs {
            guard let annotation = annotationsByID[id] else {
                continue
            }

            mapView.removeAnnotation(annotation)
            annotationsByID.removeValue(forKey: id)
        }
    }

    private func updateExistingAnnotations(
        locationsByID: [UUID: Location],
        on mapView: MKMapView
    ) {
        for (id, annotation) in annotationsByID {
            guard let location = locationsByID[id] else {
                continue
            }

            let newCoordinate = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )

            annotation.coordinate = newCoordinate

            guard annotation.color != location.color else {
                continue
            }

            annotation.color = location.color

            guard let annotationView = mapView.view(
                for: annotation
            ) as? LocationAnnotationView else {
                continue
            }

            annotationView.updateAppearance()
        }
    }
    

    private func addNewAnnotations(
        locationsByID: [UUID: Location],
        to mapView: MKMapView
    ) {
        let newLocations = locationsByID.values.filter {
            annotationsByID[$0.id] == nil
        }

        let newAnnotations = newLocations.map {
            annotationFactory.makeAnnotation(for: $0)
        }

        for annotation in newAnnotations {
            annotationsByID[annotation.locationID] = annotation
        }

        mapView.addAnnotations(newAnnotations)
    }
}
