//
//  ContentView.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 18.06.2024.
//

import SwiftUI

struct ContentView: View {
    @State var id: CancelID? = CancelID()
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
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            if id != nil {
                Button("Cancel") {
                    id = nil
                }
            } else {
                Button("Restart") {
                    id = CancelID()
                }
            }
        }
        .padding()
        .task(id: id) {
            guard id != nil else {
                print("Task not started")
                return
            }
            print("Task started")
            await viewModel.loadImage()
        }
    }

    struct CancelID: Equatable {}
}

#Preview {
    ContentView()
}
