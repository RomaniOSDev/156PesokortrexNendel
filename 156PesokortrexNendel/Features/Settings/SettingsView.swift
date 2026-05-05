//
//  SettingsView.swift
//  156PesokortrexNendel
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var productivity: ProductivityData
    @State private var confirmReset = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Workspace Insights")
                    .productivityTitleStyle()

                Text("Monitor cumulative signals sourced from your sessions.")
                    .productivitySecondaryStyle()
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                statGrid

                difficultySurface

                supportSection

                Button(role: .destructive) {
                    confirmReset = true
                } label: {
                    Text("Reset All Progress")
                        .productivityBodyStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .productivityPrimaryButtonShape(cornerRadius: 16)
                }
                .buttonStyle(.plain)
                .confirmationDialog(
                    "Reset All Progress",
                    isPresented: $confirmReset,
                    titleVisibility: .visible
                ) {
                    Button("Reset Everything", role: .destructive) {
                        productivity.resetProgress()
                        NotificationCenter.default.post(name: .resetDashboardNavigation, object: nil)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This clears onboarding status, achievements, stars, and planner goals.")
                }

                Spacer(minLength: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .productivityScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: .productivityDataDidReset)) { _ in
            confirmReset = false
        }
    }

    private var statGrid: some View {
        VStack(spacing: 12) {
            statRow(title: "Sessions logged", value: "\(productivity.sessionsFinishedCount())")
            statRow(title: "Total stars", value: "\(productivity.totalStarsEarned())")
            statRow(title: "Tracked streak high", value: "\(productivity.dailyStreaks)d")
            statRow(title: "Active bottlenecks", value: "\(productivity.identifiedBottlenecks)")
            statRow(title: "Completion samples", value: "\(productivity.taskCompletionRates.count)")
            statRow(title: "Achievements", value: productivity.hasUnlockedMilestone ? "Unlocked" : "None yet")
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .productivityBodyStyle()
            Spacer()
            Text(value)
                .productivityCaptionStyle()
        }
        .padding(.vertical, 6)
    }

    private var difficultySurface: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Default Difficulty")
                .productivityBodyStyle()
            Picker("Difficulty", selection: $productivity.difficultyTierRaw) {
                ForEach(DifficultyTier.allCases) { tier in
                    Text(tier.title).tag(tier.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support & Legal")
                .productivityBodyStyle()

            Button {
                ProductivityFeedback.light()
                rateApp()
            } label: {
                settingsRowLabel(title: "Rate Us", symbolName: "star.fill")
            }
            .buttonStyle(ScalePressButtonStyle(scale: 0.98))

            Button {
                ProductivityFeedback.light()
                openExternalURL(.privacyPolicy)
            } label: {
                settingsRowLabel(title: "Privacy Policy", symbolName: "hand.raised.fill")
            }
            .buttonStyle(ScalePressButtonStyle(scale: 0.98))

            Button {
                ProductivityFeedback.light()
                openExternalURL(.termsOfUse)
            } label: {
                settingsRowLabel(title: "Terms of Use", symbolName: "doc.text.fill")
            }
            .buttonStyle(ScalePressButtonStyle(scale: 0.98))
        }
    }

    private func settingsRowLabel(title: String, symbolName: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbolName)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 28, alignment: .center)

            Text(title)
                .productivityBodyStyle()

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary.opacity(0.7))
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private func openExternalURL(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
