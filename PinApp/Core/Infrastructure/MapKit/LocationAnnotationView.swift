//
//  LocationAnnotationView.swift
//  PinApp
//
//  Created by I_IvanM on 18.08.2026.
//

import UIKit
import MapKit
import SwiftUI

final class LocationAnnotationView: MKAnnotationView {

    static let reuseIdentifier = "LocationAnnotationView"

    private let circleView = UIView()
    private let centerDotView = UIView()

    override var annotation: MKAnnotation? {
        didSet {
            updateAppearance()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(
            annotation: annotation,
            reuseIdentifier: reuseIdentifier
        )

        configure()
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configure()
        updateAppearance()
    }

    private func configure() {
        frame = CGRect(
            x: 0,
            y: 0,
            width: 14,
            height: 14
        )

        centerOffset = .zero
        backgroundColor = .clear

        circleView.frame = bounds
        circleView.layer.cornerRadius = bounds.width / 2
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor.white.cgColor
        circleView.isUserInteractionEnabled = false
        addSubview(circleView)

        centerDotView.frame = CGRect(
            x: 5,
            y: 5,
            width: 4,
            height: 4
        )
        centerDotView.layer.cornerRadius = 2
        centerDotView.backgroundColor = .white
        centerDotView.isUserInteractionEnabled = false
        addSubview(centerDotView)
    }

    func updateAppearance() {
        guard let annotation = annotation as? LocationAnnotation else {
            return
        }

        guard let color = Color(hex: annotation.color) else {return}

        circleView.backgroundColor = UIColor(color)
    }
}
