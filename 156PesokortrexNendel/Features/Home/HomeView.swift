//
//  HomeView.swift
//  156PesokortrexNendel
//

import Combine
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var productivity: ProductivityData
    @EnvironmentObject private var tabRouter: TabRouter

    private let widgetColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    headerSection

                    heroBanner

                    LazyVGrid(columns: widgetColumns, spacing: 12) {
                        HomeMetricWidget(
                            symbolName: "flame.fill",
                            symbolTint: Color.appAccent,
                            title: "Streak",
                            value: "\(productivity.dailyStreaks)d",
                            caption: "Daily rhythm"
                        ) {
                            tabRouter.openDashboard()
                        }

                        HomeMetricWidget(
                            symbolName: "checkmark.circle.fill",
                            symbolTint: Color.appPrimary,
                            title: "Sessions",
                            value: "\(productivity.sessionsFinishedCount())",
                            caption: "Finished runs"
                        ) {
                            tabRouter.openAnalytics()
                        }

                        HomeMetricWidget(
                            symbolName: "sparkles",
                            symbolTint: Color.appAccent,
                            title: "Stars",
                            value: "\(productivity.totalStarsEarned())",
                            caption: "Across activities"
                        ) {
                            tabRouter.openDashboard()
                        }

                        HomeMetricWidget(
                            symbolName: "chart.bar.fill",
                            symbolTint: Color.appPrimary,
                            title: "Goals",
                            value: goalsSummary,
                            caption: "Planner blend"
                        ) {
                            tabRouter.openPlanner()
                        }
                    }

                    quickActionsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 350_000_000)
                await MainActor.run {
                    productivity.objectWillChange.send()
                    ProductivityFeedback.light()
                }
            }
            .productivityScreenBackdrop()
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingTitle)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("A calm snapshot of where you stand.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroBanner: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.55),
                            Color.appAccent.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Image(systemName: "sun.horizon.fill")
                        .font(.system(size: 72, weight: .ultraLight))
                        .foregroundStyle(Color.white.opacity(0.22))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("Today")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.white.opacity(0.85))

                Text("Small steps. Clear progress.")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.96))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(difficultyLine)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .lineLimit(1)
            }
            .padding(20)
        }
        .frame(minHeight: 132)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .productivityFloatingElevation(cornerRadius: 22)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shortcuts")
                .productivityTitleStyle()

            NavigationLink {
                ModuleSelectionView()
            } label: {
                HomeShortcutRow(
                    symbolName: "play.circle.fill",
                    title: "Start an activity",
                    subtitle: "Pick a module and level"
                )
            }
            .buttonStyle(ScalePressButtonStyle(scale: 0.98))

            Button {
                ProductivityFeedback.light()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                    tabRouter.openDashboard()
                }
            } label: {
                HomeShortcutRow(
                    symbolName: "square.grid.2x2.fill",
                    title: "Open dashboard",
                    subtitle: "Levels and starred runs"
                )
            }
            .buttonStyle(ScalePressButtonStyle(scale: 0.98))
        }
    }

    private var greetingTitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 12: return "Good morning"
        case 12 ..< 17: return "Good afternoon"
        case 17 ..< 22: return "Good evening"
        default: return "Hello"
        }
    }

    private var goalsSummary: String {
        let goals = productivity.plannerGoalProgress
        guard goals.isEmpty == false else { return "—" }
        let avg = goals.reduce(0, +) / Double(goals.count)
        let percent = Int((avg * 100).rounded())
        return "\(percent)%"
    }

    private var difficultyLine: String {
        "Difficulty: \(productivity.difficultyTier.title)"
    }
}

// MARK: - Pieces

private struct HomeMetricWidget: View {
    let symbolName: String
    let symbolTint: Color
    let title: String
    let value: String
    let caption: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            ProductivityFeedback.light()
            action()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(symbolTint.opacity(0.18))
                        .frame(width: 44, height: 44)

                    Image(systemName: symbolName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(symbolTint)
                }

                Text(title)
                    .productivityCaptionStyle()
                    .foregroundStyle(Color.appTextSecondary)

                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(caption)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .productivityDepthCard(cornerRadius: 18)
        }
        .buttonStyle(ScalePressButtonStyle(scale: 0.97))
    }
}

private struct HomeShortcutRow: View {
    let symbolName: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbolName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 40, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .productivityBodyStyle()
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary.opacity(0.7))
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }
}

#if DEBUG
#Preview {
    HomeView()
        .environmentObject(ProductivityData())
        .environmentObject(TabRouter())
}
#endif
