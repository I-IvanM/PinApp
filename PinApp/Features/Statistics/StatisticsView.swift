//
//  StatisticsView.swift
//  PinApp
//
//  Created by I_IvanM on 28.07.2026.
//

import Foundation
import SwiftUI

struct StatisticsView: View {

    let dependencies: AppDependencies

    @State private var statistics: StatisticsValues?

    var body: some View {
        ZStack {
            background

            if let statistics {
                ScrollView {
                    StatisticsWorldMap(
                        countryCount: statistics.countryCount,
                        visitedCountryCount: statistics.visitedCountryCount,
                        visitedCountries: statistics.visitedCountries,
                        polygonSearch: dependencies.polygonSearch,
                        settingsService: dependencies.settingsService
                    )

                    StatisticsContinentRow(
                        statistics: statistics
                    )

                    if !statistics.visitedCountries.isEmpty {
                        StatisticsCountryRow(
                            countries: statistics.visitedCountries,
                            polygonSearch: dependencies.polygonSearch
                        )
                    }

                    StatisticsLocationTypes(
                        statistics: statistics
                    )
                    
                 //   Spacer()
                }
                .padding()
                .scrollClipDisabled()
            }
        }
        .onAppear {
            updateStatistics()
        }
        .onChange(of: dependencies.updateService.statisticsUpdate) {
            updateStatistics()
        }
    }

    private var background: some View {
        Color("SettingsBackground")
            .ignoresSafeArea()
    }

    private func updateStatistics() {
        do {
            statistics = try dependencies.statisticsService.calculate()
        } catch {
            print("Failed to calculate statistics: \(error)")
        }
    }
}
