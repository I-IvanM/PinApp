//
//  NetworkMonitor.swift
//  PinApp
//
//  Created by I_IvanM on 09.08.2026.
//

import Foundation
import Network

final class NetworkMonitor {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private(set) var isConnected = false

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            self.isConnected = path.status == .satisfied
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
