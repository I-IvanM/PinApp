//
//  StatisticsLocationTypes.swift
//  PinApp
//
//  Created by I_IvanM on 23.08.2026.
//

import Foundation
import SwiftUI

struct StatisticsLocationTypes: View {

    let statistics: StatisticsValues

    private let locationTypes: [
        (
            icon: String,
            count: KeyPath<StatisticsValues, Int>
        )
    ] = [
        ("mappin", \.pointCount),
        ("building.2", \.cityCount),
        ("mountain.2", \.mountainCount)
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(
            columns: columns,
            spacing: 10
        ) {
            ForEach(
                Array(locationTypes.enumerated()),
                id: \.offset
            ) { _, locationType in

                StatisticsLocationItem(
                    icon: locationType.icon,
                    count: statistics[keyPath: locationType.count]
                )
            }
        }
    }
}

// MARK: - Location Item

private struct StatisticsLocationItem: View {

    let icon: String
    let count: Int

    var body: some View {
        HStack(spacing: 8) {

            Image(systemName: icon)

            Text("\(count)")
                .monospacedDigit()
        }
        .font(
            .system(
                size: 18,
                weight: .semibold
            )
        )
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 18)
        )
    }
}
