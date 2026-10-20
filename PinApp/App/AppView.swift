//
//  AppView.swift
//  PinApp
//
//  Created by I_IvanM on 27.07.2026.
//

import Foundation
import SwiftUI

struct AppView: View {

    let dependencies: AppDependencies

    var body: some View {
        TabView {
            MapView(dependencies: dependencies)
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            PinListView(dependencies: dependencies)
                .tabItem {
                    Label("Pins", systemImage: "mappin")
                }

            StatisticsView(dependencies: dependencies)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }

            SettingsView(dependencies: dependencies)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
