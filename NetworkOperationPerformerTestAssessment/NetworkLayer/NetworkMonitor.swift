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
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied)
            }
        }
    }
    
    func hasInternetConnection() -> Bool {
        isConnected
    }

    func startMonitoringIfRequired() {
        guard !isStarted else { return }
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task {
                await self.updateStatus(path: path)
            }
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }

    // MARK: - Private methods

    private func updateStatus(path: NWPath) {
        isConnected = path.status == .satisfied
    }
    
}
