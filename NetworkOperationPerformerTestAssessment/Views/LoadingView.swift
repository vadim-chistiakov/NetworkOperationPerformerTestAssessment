//
//  LoadingView.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 20.06.2024.
//

import SwiftUI

struct LoadingView: View {
    
    var cancelAction: () -> ()
    
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
            Button("Cancel") {
                cancelAction()
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
}
