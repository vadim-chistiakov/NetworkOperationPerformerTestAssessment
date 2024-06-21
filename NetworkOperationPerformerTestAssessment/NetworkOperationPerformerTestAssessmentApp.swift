//
//  NetworkOperationPerformerTestAssessmentApp.swift
//  NetworkOperationPerformerTestAssessment
//
//  Created by Vadim Chistiakov on 18.06.2024.
//

import SwiftUI

@main
struct NetworkOperationPerformerTestAssessmentApp: App {

    @State var isContentOpened = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Button("Open content") {
                    isContentOpened = true
                }
                .navigationDestination(isPresented: $isContentOpened) {
                    ContentView()
                }
            }
        }
    }
}
