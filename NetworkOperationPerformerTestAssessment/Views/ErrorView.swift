//
//  ErrorView.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 20.06.2024.
//

import SwiftUI

struct ErrorView: View {
    @Binding var errorMessage: String?
    
    var body: some View {
        Text(errorMessage ?? "")
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.all)
    }
}
