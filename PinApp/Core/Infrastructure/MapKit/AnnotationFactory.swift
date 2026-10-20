//
//  AnnotationFactory.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import MapKit

final class AnnotationFactory {

    func makeAnnotation(
        for location: Location
    ) -> LocationAnnotation {
        return LocationAnnotation(location: location)
    }

    func makeView(
        for annotation: MKAnnotation,
        in mapView: MKMapView
    ) -> MKAnnotationView {
        let reuseIdentifier = LocationAnnotationView.reuseIdentifier

        let annotationView: LocationAnnotationView

        if let reusableView = mapView.dequeueReusableAnnotationView(
            withIdentifier: reuseIdentifier
        ) as? LocationAnnotationView {
            annotationView = reusableView
        } else {
            annotationView = LocationAnnotationView(
                annotation: annotation,
                reuseIdentifier: reuseIdentifier
            )
        }

        annotationView.annotation = annotation
        annotationView.canShowCallout = false

        return annotationView
    }
}
