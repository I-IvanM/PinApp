//
//  UpdateService.swift
//  PinApp
//
//  Created by I_IvanM on 18.08.2026.
//

import Foundation
import Observation

@Observable
final class UpdateService {

    private(set) var mapUpdate = 0
    private(set) var pinListUpdate = 0
    private(set) var statisticsUpdate = 0

    func notifyMapUpdate() {
        mapUpdate = (mapUpdate + 1) % 2
    }

    func notifyPinListUpdate() {
        pinListUpdate = (pinListUpdate + 1) % 2
    }

    func notifyStatisticsUpdate() {
        statisticsUpdate = (statisticsUpdate + 1) % 2
    }
}
