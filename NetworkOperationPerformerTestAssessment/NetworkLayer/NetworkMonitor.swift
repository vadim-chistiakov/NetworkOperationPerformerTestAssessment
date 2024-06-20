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

    init(monitor: NWPathMonitor = .init())  {
        self.monitor = monitor
        // TODO: - Actor-isolated instance method 'startMonitoring()' can not be referenced from a non-isolated context; this is an error in Swift 6
        startMonitoring()
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
    
    // MARK: - Private methods
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task {
                await self.updateStatus(path: path)
            }
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
    
    private func updateStatus(path: NWPath) {
        isConnected = path.status == .satisfied
    }
    
}
