//
//  LevelPickerView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct LevelPickerView: View {
    let activity: ActivityKind
    @Binding var path: NavigationPath
    @EnvironmentObject private var productivity: ProductivityData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose Stage Depth")
                    .productivityTitleStyle()

                Text(activity.summary)
                    .productivitySecondaryStyle()
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(0..<3, id: \.self) { level in
                    Button {
                        ProductivityFeedback.light()
                        path.append(DashboardRoute.session(activity, level))
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Level \(level + 1)")
                                    .productivityBodyStyle()
                                Text(levelDescriptor(for: level))
                                    .productivityCaptionStyle()
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            if productivity.isLevelUnlocked(activity: activity, level: level) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundStyle(Color.appAccent)
                            } else {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                        .padding(16)
                        .productivityDepthCard(cornerRadius: 18)
                    }
                    .buttonStyle(ScalePressButtonStyle(scale: 0.98))
                    .disabled(productivity.isLevelUnlocked(activity: activity, level: level) == false)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .productivityScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
    }

    private func levelDescriptor(for level: Int) -> String {
        switch activity {
        case .processDissection:
            return ["Baseline routing grid", "Dense overlap scenario", "Executive-ready lattice"][level]
        case .momentumBuilder:
            return ["Stabilize cadence", "Stretch streak runway", "Precision reinforcement"][level]
        case .workflowChallenge:
            return ["Warm alignment sprint", "Compressed sequencing", "Mission-critical tempo"][level]
        }
    }
}
