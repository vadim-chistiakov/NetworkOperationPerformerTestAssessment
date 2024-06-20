//
//  NetworkOperationPerformer.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 18.06.2024.
//

import Foundation
import Network

final class NetworkOperationPerformer {
    
    private let networkMonitor: NetworkMonitor

    init(networkMonitor: NetworkMonitor = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }
    
    /// Executes a given asynchronous network operation and ensures it completes within a specified time limit.
    ///
    /// This method runs the provided network operation in a new task, allowing it to be canceled if needed.
    ///
    /// - Parameters:
    ///   - closure: An asynchronous closure representing the network operation to be performed.
    ///   - withinSeconds: A `TimeInterval` specifying the time limit in seconds within which the operation should complete.
    func performNetworkOperation(
        using closure: @escaping () async -> Void,
        withinSeconds timeoutDuration: TimeInterval
    ) async throws {
        if await networkMonitor.hasInternetConnection() {
            await closure()
        } else {
            try await tryPerformingNetworkOperation(using: closure, withinSeconds: timeoutDuration)
        }
    }
    
    // MARK: - Private method

    private func tryPerformingNetworkOperation(
        using closure: @escaping () async -> Void,
        withinSeconds timeoutDuration: TimeInterval
    ) async throws {
        let timeoutTask = Task {
            try await Task.sleep(seconds: timeoutDuration)
        }
        let networkChangeTask = Task { [weak self] in
            guard let self = self else { return }
            for await isConnected in await self.networkMonitor.addNetworkStatusChangeObserver() {
                if !Task.isCancelled, isConnected {
                    await closure()
                    timeoutTask.cancel()
                    return
                }
            }
        }

        let result = await timeoutTask.result
        if case .success = result {
            networkChangeTask.cancel()
            throw NetworkError.timeoutError
        }
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds duration: TimeInterval) async throws {
        try await sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}
