//
//  NetworkService.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 20.06.2024.
//

import SwiftUI

protocol NetworkService {
    func fetchImage(from url: URL) async throws -> Image
}

final class NetworkServiceImpl: NetworkService {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetchImage(from url: URL) async throws -> Image {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let uiImage = UIImage(data: data) else {
            throw NetworkError.requestFailed
        }
        return Image(uiImage: uiImage)
    }
}
