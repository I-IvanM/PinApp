//
//  StatisticsCountryRow.swift
//  PinApp
//
//  Created by I_IvanM on 23.08.2026.
//

import Foundation
import SwiftUI
@preconcurrency import MapKit

struct StatisticsCountryRow: View {

    let countries: [Country]
    let polygonSearch: PolygonSearch
    
    private var sortedCountries: [Country] {
        countries.sorted {
            if $0.countryPinCount != $1.countryPinCount {
                return $0.countryPinCount > $1.countryPinCount
            }

            return $0.countryName.localizedCaseInsensitiveCompare(
                $1.countryName
            ) == .orderedAscending
        }
    }

    @State private var pathsByCountryID: [String: Path] = [:]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(sortedCountries, id: \.countryID) { country in
                    StatisticsCountryItem(
                        country: country,
                        path: pathsByCountryID[country.countryID]
                    )
                }
            }
        }
        .scrollClipDisabled()
        .onAppear {loadCountryPaths()}
    }

    // MARK: - Private
    
    private func polygonArea(_ polygon: MKPolygon) -> Double {
        let mapRect = polygon.boundingMapRect

        return mapRect.size.width * mapRect.size.height
    }

    private func loadCountryPaths() {
        let sortedCountries = sortedCountries
        let polygons = polygonSearch.search(countries: sortedCountries)

        var paths: [String: Path] = [:]

        for (country, polygon) in zip(sortedCountries, polygons) {
            paths[country.countryID] = makePath(from: polygon)
        }

        pathsByCountryID = paths
    }

    private func makePath(from polygon: MKMultiPolygon) -> Path {
        var points: [CGPoint] = []
        var rings: [Range<Int>] = []

        if let mainPolygon = polygon.polygons.max(
            by: { polygonArea($0) < polygonArea($1) }
        ) {
            let startIndex = points.count

            appendPoints(
                from: mainPolygon,
                to: &points
            )

            let endIndex = points.count

            if startIndex < endIndex {
                rings.append(startIndex..<endIndex)
            }
        }

        guard
            !points.isEmpty,
            let minX = points.map(\.x).min(),
            let maxX = points.map(\.x).max(),
            let minY = points.map(\.y).min(),
            let maxY = points.map(\.y).max()
        else {
            return Path()
        }

        let width = maxX - minX
        let height = maxY - minY

        guard width > 0, height > 0 else {
            return Path()
        }

        let scale = 1 / max(width, height)

        var path = Path()

        for ring in rings {
            for index in ring {
                let point = points[index]

                let normalizedPoint = CGPoint(
                    x: (point.x - minX) * scale,
                    y: (point.y - minY) * scale
                )

                if index == ring.lowerBound {
                    path.move(to: normalizedPoint)
                } else {
                    path.addLine(to: normalizedPoint)
                }
            }

            path.closeSubpath()
        }

        return path
    }

    private func appendPoints(
        from polygon: MKPolygon,
        to points: inout [CGPoint]
    ) {
        guard polygon.pointCount > 0 else {
            return
        }

        let polygonPoints = polygon.points()

        for index in 0..<polygon.pointCount {
            let point = polygonPoints[index]

            points.append(
                CGPoint(
                    x: point.x,
                    y: point.y
                )
            )
        }

        if let interiorPolygons = polygon.interiorPolygons {
            for interiorPolygon in interiorPolygons {
                appendPoints(
                    from: interiorPolygon,
                    to: &points
                )
            }
        }
    }
}

// MARK: - Country Item

private struct StatisticsCountryItem: View {

    let country: Country
    let path: Path?

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if let path {
                    StatisticsCountryShape(path: path)
                        .fill(.gray.opacity(0.35))
                        .overlay {
                            StatisticsCountryShape(path: path)
                                .stroke(
                                    .gray.opacity(0.35),
                                    style: StrokeStyle(
                                        lineWidth: 2,
                                        lineJoin: .round
                                    )
                                )
                        }
                        .padding(10)
                }

                pinCount
            }
            .frame(width: 110, height: 110)

            Text(country.countryName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 110)
        .padding(.bottom, 6)
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 24)
        )
    }

    private var pinCount: some View {
        HStack(spacing: 4) {
            Text("\(country.countryPinCount)")

            Image(systemName: "mappin")
        }
        .font(.system(size: 32, weight: .bold))
        .foregroundStyle(.primary)
        .shadow(
            color: .primary.opacity(0.25),
            radius: 2
        )
    }
}

// MARK: - Country Shape

private struct StatisticsCountryShape: Shape {

    let path: Path

    func path(in rect: CGRect) -> Path {
        let bounds = path.boundingRect

        guard bounds.width > 0, bounds.height > 0 else {
            return Path()
        }

        let scale = min(
            rect.width / bounds.width,
            rect.height / bounds.height
        )

        let scaledWidth = bounds.width * scale
        let scaledHeight = bounds.height * scale

        let offsetX = (rect.width - scaledWidth) / 2
        let offsetY = (rect.height - scaledHeight) / 2

        let transform = CGAffineTransform(
            translationX: offsetX,
            y: offsetY
        )
        .scaledBy(
            x: scale,
            y: scale
        )
        .translatedBy(
            x: -bounds.minX,
            y: -bounds.minY
        )

        return path.applying(transform)
    }
}
