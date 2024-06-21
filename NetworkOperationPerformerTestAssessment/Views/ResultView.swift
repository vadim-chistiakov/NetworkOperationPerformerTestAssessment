//
//  ResultView.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 21.06.2024.
//

import SwiftUI

struct ResultView: View {
    
    @ObservedObject var viewModel: ImageLoaderViewModel

    var body: some View {
        VStack {
            if let image = viewModel.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .transition(.opacity)
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Result screen")
    }
    
}

#Preview {
    ResultView(viewModel: ImageLoaderViewModel())
}
