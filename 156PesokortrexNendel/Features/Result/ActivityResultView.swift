//
//  ActivityResultView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct ActivityResultView: View {
    let payload: ActivityResultPayload

    @EnvironmentObject private var productivity: ProductivityData
    @EnvironmentObject private var tabRouter: TabRouter
    @Environment(\.dismiss) private var dismiss

    @State private var revealedStars = 0
    @State private var showAchievementBanner = false
    @State private var highlightedAchievement: AchievementID?
    @State private var committed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Session Report")
                    .productivityTitleStyle()

                starStrip

                VStack(alignment: .leading, spacing: 10) {
                    Text(moduleLine)
                        .productivityBodyStyle()
                    Text("Benchmark alignment \(payload.benchmarkPercent)%")
                        .productivityCaptionStyle()
                    Text("Completion intensity \(Int(payload.completionRate * 100))%")
                        .productivityCaptionStyle()
                    Text("Streak context \(payload.streakLength)d")
                        .productivityCaptionStyle()
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .productivityDepthCard(cornerRadius: 18)

                HStack(spacing: 12) {
                    Button {
                        tabRouter.openPlanner()
                        NotificationCenter.default.post(name: .resetDashboardNavigation, object: nil)
                        dismiss()
                    } label: {
                        Text("View Progress")
                            .productivityBodyStyle()
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .productivityPrimaryButtonShape(cornerRadius: 16)
                    }
                    .buttonStyle(ScalePressButtonStyle(scale: 0.98))

                    Button {
                        tabRouter.openDashboard()
                        NotificationCenter.default.post(name: .resetDashboardNavigation, object: nil)
                        dismiss()
                    } label: {
                        Text("Dashboard")
                            .productivityBodyStyle()
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .productivitySecondaryPlate(cornerRadius: 16)
                    }
                    .buttonStyle(ScalePressButtonStyle(scale: 0.98))
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .productivityScreenBackdrop()
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .top) {
            if showAchievementBanner, let achievement = highlightedAchievement {
                achievementBanner(for: achievement)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            commitChanges()
            animateStarsIfNeeded()
        }
    }

    private var moduleLine: String {
        "\(payload.activity.title) • Stage \(payload.level + 1)"
    }

    private var starStrip: some View {
        HStack(spacing: 18) {
            ForEach(0..<3, id: \.self) { index in
                let active = index < revealedStars && index < payload.stars
                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(active ? Color.appAccent : Color.appSurface.opacity(0.45))
                    .scaleEffect(active ? 1 : 0.78)
                    .opacity(active ? 1 : 0.45)
                    .shadow(color: active ? Color.appAccent.opacity(0.85) : Color.clear, radius: active ? 10 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: revealedStars)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .productivityInsetPanel(cornerRadius: 18)
    }

    private func animateStarsIfNeeded() {
        revealedStars = 0
        for index in 1...payload.stars {
            let delay = Double(index) * 0.18
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    revealedStars = index
                }
            }
        }
    }

    private func achievementBanner(for achievement: AchievementID) -> some View {
        Text("Achievement • \(productivity.achievementTitle(for: achievement))")
            .productivityBodyStyle()
            .foregroundStyle(Color.appTextPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.98),
                                Color.appPrimary.opacity(0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.35), radius: 18, y: 12)
            .padding(.horizontal, 16)
    }

    private func commitChanges() {
        guard committed == false else { return }
        committed = true

        productivity.setStars(activity: payload.activity, level: payload.level, stars: payload.stars)

        let bottleneckDelta: Int
        switch payload.activity {
        case .processDissection:
            if payload.stars >= 2 {
                bottleneckDelta = -1
            } else if payload.benchmarkPercent < 55 {
                bottleneckDelta = 1
            } else {
                bottleneckDelta = 0
            }
        case .momentumBuilder:
            bottleneckDelta = payload.streakLength >= 4 ? -1 : 0
        case .workflowChallenge:
            bottleneckDelta = payload.benchmarkPercent >= 78 ? -1 : 1
        }

        let snapshot = payload.momentumSnapshot ?? productivity.momentumSavedDays()

        productivity.recordSessionCompletion(
            rate: payload.completionRate,
            bottleneckDelta: bottleneckDelta,
            momentumSnapshot: snapshot
        )

        productivity.updateTrackedStreak(payload.streakLength)
        productivity.advancePlannerGoals(by: Double(payload.stars) * 0.018 + 0.012)

        let unlocked = productivity.evaluateNewAchievements(
            activity: payload.activity,
            starsEarned: payload.stars,
            streakLength: payload.streakLength,
            benchmarkPercent: payload.benchmarkPercent
        )

        if let unlocked {
            highlightedAchievement = unlocked
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showAchievementBanner = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAchievementBanner = false
                }
            }
        }
    }
}
