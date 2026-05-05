//
//  EfficiencyPlannerView.swift
//  156PesokortrexNendel
//

import Combine
import SwiftUI

struct EfficiencyPlannerView: View {
    @EnvironmentObject private var productivity: ProductivityData

    private let goalTitles = [
        "Deep Work Blocks",
        "Cross-team Alignment",
        "QA Throughput"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    Text("Efficiency Planner")
                        .productivityTitleStyle()

                    Text("Tap − / + to nudge goals, or pull to refresh synced stats.")
                        .productivitySecondaryStyle()
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(goalTitles.indices, id: \.self) { index in
                        goalCard(title: goalTitles[index], index: index, progress: progress(for: index))
                    }

                    NavigationLink {
                        ModuleSelectionView()
                    } label: {
                        HStack {
                            Text("Open Module Selection")
                                .productivityBodyStyle()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.appAccent)
                        }
                        .padding(16)
                        .productivityDepthCard(cornerRadius: 18)
                    }
                    .buttonStyle(ScalePressButtonStyle(scale: 0.98))

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 400_000_000)
                await MainActor.run {
                    productivity.objectWillChange.send()
                    ProductivityFeedback.light()
                }
            }
            .productivityScreenBackdrop()
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func progress(for index: Int) -> Double {
        let values = productivity.plannerGoalProgress
        guard values.indices.contains(index) else {
            return 0.35
        }
        return values[index]
    }

    private func goalCard(title: String, index: Int, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .productivityBodyStyle()
                Spacer()
                Text(statusLabel(for: progress))
                    .productivityCaptionStyle()
            }

            ProgressView(value: progress)
                .tint(Color.appAccent)

            Text("Progress \(Int(progress * 100))%")
                .productivityCaptionStyle()

            HStack(spacing: 12) {
                Button {
                    productivity.adjustPlannerGoal(at: index, delta: -0.06)
                    ProductivityFeedback.light()
                } label: {
                    Text("Trim")
                        .productivityCaptionStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .productivitySecondaryPlate(cornerRadius: 14)
                }
                .buttonStyle(ScalePressButtonStyle(scale: 0.96))

                Button {
                    productivity.adjustPlannerGoal(at: index, delta: 0.06)
                    ProductivityFeedback.light()
                } label: {
                    Text("Boost")
                        .productivityCaptionStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .productivityPrimaryButtonShape(cornerRadius: 14)
                }
                .buttonStyle(ScalePressButtonStyle(scale: 0.96))
            }
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private func statusLabel(for progress: Double) -> String {
        switch progress {
        case ..<0.35:
            return "Focus"
        case ..<0.7:
            return "Advancing"
        default:
            return "Stable"
        }
    }
}
