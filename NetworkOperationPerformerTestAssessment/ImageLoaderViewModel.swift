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

@MainActor
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

    func loadImage(durationSeconds: TimeInterval = 5) async {
        isLoading = true
        errorMessage = nil
        do {
            try await networkPerformer.performNetworkOperation(using: {
                do {
                    try await self.updateDownloadedImage()
                } catch {
                    await self.showErrorState(.somethingWentWrong)
                }
            }, withinSeconds: durationSeconds)

            try await Task.sleep(seconds: durationSeconds)
            showImageState()
        } catch {
            print(error)
            showErrorState(
                error is CancellationError ? .requestWasCancelled : .somethingWentWrong
            )
        }
    }

    func cancelLoading() {
        updateCancelState(.requestWasCancelled)
    }
    
    // MARK: - Private methods

    private func updateDownloadedImage() async throws {
        downloadedImage = try await downloadImage()
    }

    private func downloadImage() async throws -> Image {
        guard let url = urlExample else {
            throw NetworkError.urlIsInvalid
        }
        return try await networkService.fetchImage(from: url)
    }

    private func updateCancelState(_ error: NetworkError) {
        self.isLoading = false
        self.errorMessage = error.message
    }

    private func showImageState() {
        image = downloadedImage
        errorMessage = image == nil ? NetworkError.somethingWentWrong.message : nil
        isLoading = false
    }

    private func showErrorState(_ error: NetworkError) {
        self.errorMessage = error.message
        isLoading = false
    }
}
