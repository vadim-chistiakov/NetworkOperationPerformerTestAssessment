//
//  NetworkMonitor.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 18.06.2024.
//

import Foundation
import Network

actor NetworkMonitor {
    
    private let monitor: NWPathMonitor
    private var isConnected = false
    private var isStarted = false

    init(monitor: NWPathMonitor = .init())  {
        self.monitor = monitor
    }
    
    func addNetworkStatusChangeObserver() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            monitor.pathUpdateHandler = { [weak self] path in
                guard let self else { return }
                let isConnected = path.status == .satisfied
                continuation.yield(isConnected)
                Task {
                    await self.updateStatus(isConnected)
                }
            }
            monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
        }
    }
    
    func hasInternetConnection() -> Bool {
        isConnected
    }

    // MARK: - Private methods

    private func updateStatus(_ isConnected: Bool) {
        self.isConnected = isConnected
    }
    
}
