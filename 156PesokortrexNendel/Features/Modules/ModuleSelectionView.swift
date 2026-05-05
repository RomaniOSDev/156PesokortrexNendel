//
//  ModuleSelectionView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct ModuleSelectionView: View {
    @EnvironmentObject private var productivity: ProductivityData

    private struct ModuleItem: Identifiable {
        let id = UUID()
        let title: String
        let detail: String
        let progress: Double
    }

    private var modules: [ModuleItem] {
        let goals = productivity.plannerGoalProgress
        return [
            ModuleItem(
                title: "Delivery Rhythm",
                detail: "Sequences how work enters QA and returns to stakeholders.",
                progress: goals.indices.contains(0) ? goals[0] : 0.35
            ),
            ModuleItem(
                title: "Stakeholder Alignment",
                detail: "Measures clarity between leadership asks and contributor reality.",
                progress: goals.indices.contains(1) ? goals[1] : 0.45
            ),
            ModuleItem(
                title: "Operational Guardrails",
                detail: "Tracks safeguards that keep launches disciplined.",
                progress: goals.indices.contains(2) ? goals[2] : 0.42
            )
        ]
    }

    var body: some View {
        List {
            Section {
                Text("Expand each module to audit secondary checkpoints.")
                    .productivitySecondaryStyle()
                    .listRowBackground(
                        LinearGradient(
                            colors: [Color.appSurface, Color.appSurface.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Section {
                ForEach(modules) { module in
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 10) {
                            ProgressView(value: module.progress)
                                .tint(Color.appAccent)
                            Text("Momentum \(Int(module.progress * 100))% toward adoption targets.")
                                .productivityCaptionStyle()
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Pair this module with Analytics to validate directional shifts.")
                                .productivityCaptionStyle()
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 8)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(module.title)
                                    .productivityBodyStyle()
                                Text(module.detail)
                                    .productivityCaptionStyle()
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            progressBadge(progress: module.progress)
                        }
                        .padding(.vertical, 6)
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [Color.appSurface, Color.appSurface.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .frame(minHeight: 720)
        .padding(.bottom, 120)
        .productivityScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
    }

    private func progressBadge(progress: Double) -> some View {
        Text("\(Int(progress * 100))%")
            .productivityCaptionStyle()
            .foregroundStyle(Color.appTextPrimary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.88),
                                Color.appPrimary.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    }
                    .shadow(color: Color.appAccent.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .accessibilityLabel(Text("Progress \(Int(progress * 100)) percent"))
    }
}
