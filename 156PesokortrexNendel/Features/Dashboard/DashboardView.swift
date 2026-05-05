//
//  DashboardView.swift
//  156PesokortrexNendel
//

import Combine
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var productivity: ProductivityData
    @State private var path = NavigationPath()
    @State private var summarySheet: SummaryInsight?

    private enum SummaryInsight: String, Identifiable {
        case bottlenecks
        case streak
        case sessions

        var id: String { rawValue }

        var title: String {
            switch self {
            case .bottlenecks:
                return "Bottleneck posture"
            case .streak:
                return "Cadence streak"
            case .sessions:
                return "Structured sessions"
            }
        }

        func detail(productivity: ProductivityData) -> String {
            switch self {
            case .bottlenecks:
                return "This estimates friction points still unresolved across teams. Lower it by completing Process sessions with cleaner layouts and fewer overlaps."
            case .streak:
                return "Shows your longest momentum runway recorded from Momentum Builder. Tap days consistently to push this figure upward."
            case .sessions:
                return "Counts finished coaching sessions across every activity. Each completion feeds Analytics and unlocks deeper planner progress."
            }
        }
    }

    @State private var emphasizedTaskIndex: Int?

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    summarySurface
                    NavigationLink(value: DashboardRoute.modules) {
                        moduleSelectionRow
                    }
                    .buttonStyle(ScalePressButtonStyle(scale: 0.98))
                    ongoingTasksSection
                    NavigationLink(value: DashboardRoute.settings) {
                        settingsRow
                    }
                    .buttonStyle(ScalePressButtonStyle(scale: 0.98))
                    activityDeck
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 450_000_000)
                await MainActor.run {
                    productivity.objectWillChange.send()
                    ProductivityFeedback.light()
                }
            }
            .productivityScreenBackdrop()
            .navigationDestination(for: DashboardRoute.self) { route in
                switch route {
                case let .activityLevels(kind):
                    LevelPickerView(activity: kind, path: $path)
                case let .session(kind, level):
                    ActivitySessionCoordinator(activity: kind, level: level)
                case .modules:
                    ModuleSelectionView()
                case .settings:
                    SettingsView()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .resetDashboardNavigation)) { _ in
                path = NavigationPath()
            }
            .sheet(item: $summarySheet) { insight in
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(insight.title)
                                .productivityTitleStyle()
                            Text(insight.detail(productivity: productivity))
                                .productivitySecondaryStyle()
                                .lineLimit(12)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                    }
                    .productivityScreenBackdrop()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                summarySheet = nil
                            }
                            .foregroundStyle(Color.appAccent)
                        }
                    }
                }
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .productivityTitleStyle()
            Text("Operational clarity for demanding workflows.")
                .productivitySecondaryStyle()
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var moduleSelectionRow: some View {
        HStack {
            Text("Module Selection")
                .productivityBodyStyle()
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.appAccent)
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private var settingsRow: some View {
        HStack {
            Text("Workspace Insights")
                .productivityBodyStyle()
            Spacer()
            Image(systemName: "gearshape.fill")
                .foregroundStyle(Color.appAccent)
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
        .accessibilityLabel(Text("Open settings"))
    }

    private var summarySurface: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Live Signals")
                .productivityBodyStyle()

            HStack(spacing: 12) {
                summaryChip(kind: .bottlenecks, title: "Bottlenecks", value: "\(productivity.identifiedBottlenecks)")
                summaryChip(kind: .streak, title: "Streak", value: "\(productivity.dailyStreaks)d")
                summaryChip(kind: .sessions, title: "Sessions", value: "\(productivity.sessionsFinishedCount())")
            }

            Text("Tap a chip for context • Pull to refresh")
                .productivityCaptionStyle()

            let rates = productivity.taskCompletionRates
            let average = rates.isEmpty ? 0 : rates.reduce(0, +) / Double(rates.count)
            ProgressView(value: average)
                .tint(Color.appAccent)

            Text("Average completion intensity \(Int(average * 100))%")
                .productivityCaptionStyle()
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 20)
    }

    private func summaryChip(kind: SummaryInsight, title: String, value: String) -> some View {
        Button {
            ProductivityFeedback.light()
            summarySheet = kind
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .productivityCaptionStyle()
                Text(value)
                    .productivityBodyStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .productivityMetricBubble(cornerRadius: 14)
        }
        .buttonStyle(ScalePressButtonStyle(scale: 0.96))
    }

    private var ongoingTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focused Tasks")
                .productivityBodyStyle()

            List {
                ForEach(Array(sampleTasks().enumerated()), id: \.offset) { index, task in
                    Button {
                        ProductivityFeedback.light()
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                            emphasizedTaskIndex = emphasizedTaskIndex == index ? nil : index
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.appAccent.opacity(emphasizedTaskIndex == index ? 0.95 : 0.65))
                                .frame(width: 10, height: 44)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(task.title)
                                    .productivityBodyStyle()
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(task.detail)
                                    .productivityCaptionStyle()
                                    .lineLimit(emphasizedTaskIndex == index ? 4 : 2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 8)
                            VStack(spacing: 6) {
                                Text(task.status)
                                    .productivityCaptionStyle()
                                    .foregroundStyle(Color.appTextPrimary)
                                Image(systemName: emphasizedTaskIndex == index ? "chevron.up.circle.fill" : "chevron.down.circle")
                                    .foregroundStyle(Color.appAccent)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        LinearGradient(
                            colors: [
                                Color.appSurface,
                                Color.appSurface.opacity(0.82)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .frame(height: CGFloat(sampleTasks().count) * 74)
            .scrollDisabled(true)
            .listStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    private func sampleTasks() -> [(title: String, detail: String, status: String)] {
        [
            ("Streamline intake diagnostics", "Collapse redundant approvals across teams.", "Active"),
            ("Rebalance weekly checkpoints", "Shift workload spikes away from Fridays.", "Queued"),
            ("Codify launch safeguards", "Publish criteria before the next release gate.", "Due Soon")
        ]
    }

    private var activityDeck: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activities")
                .productivityBodyStyle()

            ForEach(ActivityKind.allCases) { kind in
                Button {
                    path.append(DashboardRoute.activityLevels(kind))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(kind.title)
                                .productivityBodyStyle()
                            Text(kind.summary)
                                .productivityCaptionStyle()
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        starSummary(for: kind)
                    }
                    .padding(16)
                    .productivityDepthCard(cornerRadius: 18)
                }
                .buttonStyle(ScalePressButtonStyle(scale: 0.98))
            }
        }
    }

    private func starSummary(for activity: ActivityKind) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { level in
                let value = productivity.stars(activity: activity, level: level)
                Text("\(value)")
                    .productivityCaptionStyle()
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appBackground.opacity(0.62),
                                        Color.appBackground.opacity(0.32)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.28), radius: 4, x: 0, y: 2)
            }
        }
    }
}
