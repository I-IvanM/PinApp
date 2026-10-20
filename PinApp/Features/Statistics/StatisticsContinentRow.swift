//
//  StatisticsContinentRow.swift
//  PinApp
//
//  Created by I_IvanM on 23.08.2026.
//

import Foundation
import SwiftUI

struct StatisticsContinentRow: View {

    let statistics: StatisticsValues

    private let continents: [
        (
            name: String,
            total: KeyPath<StatisticsValues, Int>,
            visited: KeyPath<StatisticsValues, Int>
        )
    ] = [
        ("Africa", \.africaCount, \.africaVisitedCount),
        ("Asia", \.asiaCount, \.asiaVisitedCount),
        ("Europe", \.europeCount, \.europeVisitedCount),
        ("North America", \.northAmericaCount, \.northAmericaVisitedCount),
        ("Oceania", \.oceaniaCount, \.oceaniaVisitedCount),
        ("South America", \.southAmericaCount, \.southAmericaVisitedCount),
        ("Antarctica", \.antarcticaCount, \.antarcticaVisitedCount)
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(
                    continents,
                    id: \.name
                ) { continent in
                    StatisticsContinentItem(
                        name: continent.name,
                        countryCount: statistics[keyPath: continent.total],
                        visitedCountryCount: statistics[keyPath: continent.visited]
                    )
                }
            }
        }
        .scrollClipDisabled()
    }
}

// MARK: - Continent Item

private struct StatisticsContinentItem: View {

    let name: String
    let countryCount: Int
    let visitedCountryCount: Int

    private var progress: Double {
        guard countryCount > 0 else {
            return 0
        }

        return min(
            Double(visitedCountryCount) / Double(countryCount),
            1
        )
    }

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .stroke(
                        .primary.opacity(0.18),
                        lineWidth: 14
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: progress
                    )
                    .stroke(
                        .primary,
                        style: StrokeStyle(
                            lineWidth: 14,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(visitedCountryCount)/\(countryCount)")
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }
            .frame(
                width: 80,
                height: 80
            )

            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)
        }
        .frame(
            width: 102,
            height: 126
        )
        .modifier(StatisticsContinentGlass())
    }
}

// MARK: - Glass

private struct StatisticsContinentGlass: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(
                    .regular,
                    in: .rect(cornerRadius: 18)
                )
        } else {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 18
                    )
                )
        }
    }
}
