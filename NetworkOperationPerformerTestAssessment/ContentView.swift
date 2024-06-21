//
//  ContentView.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 18.06.2024.
//

import SwiftUI

struct ContentView: View {

    @StateObject var viewModel = ImageLoaderViewModel()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            if viewModel.isLoading {
                ProgressView()
            }
            if let image = viewModel.image {
                image
                    .resizable()
                    .frame(width: 100, height: 100)
            }
        }
        .padding()
        .task {
            viewModel.loadImage()
        }
    }
}

#Preview {
    ContentView()
}
