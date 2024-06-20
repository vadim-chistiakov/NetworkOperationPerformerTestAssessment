//
//  ImageLoaderViewModel.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 19.06.2024.
//

import SwiftUI
import Combine

let urlExample = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/London_Big_Ben_Phone_box.jpg/800px-London_Big_Ben_Phone_box.jpg")

enum NetworkError: Error {
    case urlIsInvalid
    case cantConvertImage
    case requestWasCancelled
    case somethingWentWrong
    case requestFailed
    case timeoutError
    
    var message: String {
        switch self {
        case .urlIsInvalid, .cantConvertImage, .somethingWentWrong, .requestFailed, .timeoutError:
            return "Something went wrong"
        case .requestWasCancelled:
            return "Request was cancelled"
        }
    }
}

final class ImageLoaderViewModel: ObservableObject {
    
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var image: Image? = nil

    private let networkPerformer: NetworkOperationPerformer
    private let networkService: NetworkService
    
    private var currentTask: Task<Void, Never>?
    private var downloadedImage: Image?
    
    init(
        networkPerformer: NetworkOperationPerformer = .init(),
        networkService: NetworkService = NetworkServiceImpl()
    ) {
        self.networkPerformer = networkPerformer
        self.networkService = networkService
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    func loadImage(durationSeconds: TimeInterval = 5) {
        currentTask?.cancel()

        currentTask = Task {
            do {
                try await networkPerformer.performNetworkOperation(using: { [weak self] in
                    guard let self else { return }
                    do {
                        downloadedImage = try await downloadImage()
                    } catch {
                        await showErrorState(.somethingWentWrong)
                    }
                }, withinSeconds: durationSeconds)
                
                try await Task.sleep(seconds: durationSeconds)
                await showImageState()
            } catch {
                await showErrorState(
                    error is CancellationError ? .requestWasCancelled : .somethingWentWrong
                )
            }
        }
    }
    
    @MainActor 
    func cancelLoading() {
        currentTask?.cancel()
        updateCancelState(.requestWasCancelled)
    }
    
    // MARK: - Private methods

    @MainActor
    private func downloadImage() async throws -> Image {
        guard let url = urlExample else {
            throw NetworkError.urlIsInvalid
        }
        return try await networkService.fetchImage(from: url)
    }
    
    @MainActor
    private func updateCancelState(_ error: NetworkError) {
        self.isLoading = false
        self.errorMessage = error.message
    }
    
    @MainActor
    private func showImageState() {
        image = downloadedImage
        errorMessage = image == nil ? NetworkError.somethingWentWrong.message : nil
        isLoading = false
    }

    @MainActor
    private func showErrorState(_ error: NetworkError) {
        self.errorMessage = error.message
        isLoading = false
    }

}
