//
//  ContentView.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 18.06.2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = ImageLoaderViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView(cancelAction: viewModel.cancelLoading)
            } else {
                if let image = viewModel.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ErrorView(errorMessage: $viewModel.errorMessage)
                }
            }
        }
        .onAppear {
            viewModel.loadImage()
        }
        .onDisappear {
            viewModel.cancelLoading()
        }
    }
}

#Preview {
    ContentView()
}
