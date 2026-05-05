//
//  ContentView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct ContentView: View {
    @StateObject private var productivity = ProductivityData()
    @StateObject private var tabRouter = TabRouter()

    var body: some View {
        Group {
            if productivity.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView(hasCompleted: $productivity.hasSeenOnboarding)
            }
        }
        .environmentObject(productivity)
        .environmentObject(tabRouter)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
