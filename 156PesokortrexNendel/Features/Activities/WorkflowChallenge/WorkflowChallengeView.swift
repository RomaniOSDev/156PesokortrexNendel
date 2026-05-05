//
//  WorkflowChallengeView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct WorkflowChallengeView: View {
    let levelIndex: Int
    @Binding var result: ActivityResultPayload?

    @EnvironmentObject private var productivity: ProductivityData
    @StateObject private var viewModel: WorkflowChallengeViewModel
    @State private var emitted = false

    init(levelIndex: Int, result: Binding<ActivityResultPayload?>) {
        self.levelIndex = levelIndex
        _result = result
        _viewModel = StateObject(wrappedValue: WorkflowChallengeViewModel(difficulty: .medium, levelIndex: levelIndex))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Workflow Challenge")
                    .productivityTitleStyle()

                Text("Repeat the benchmark order before the countdown expires. Wrong taps reset progress.")
                    .productivitySecondaryStyle()
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                difficultyPicker

                timerSurface

                benchmarkSurface

                controlsSurface

                Button(role: .none, action: {
                    ProductivityFeedback.medium()
                    manualFinalize()
                }) {
                    Text("Submit Sequence")
                        .productivityBodyStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .productivityPrimaryButtonShape(cornerRadius: 16)
                }
                .buttonStyle(ScalePressButtonStyle(scale: 0.98))

                Spacer(minLength: 40)
            }
            .padding(16)
        }
        .productivityScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.reload(difficulty: productivity.difficultyTier, levelIndex: levelIndex)
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onChange(of: productivity.difficultyTierRaw) { _, _ in
            viewModel.reload(difficulty: productivity.difficultyTier, levelIndex: levelIndex)
            viewModel.startTimer()
        }
        .onChange(of: viewModel.isFinished) { _, finished in
            if finished {
                emitResult()
            }
        }
    }

    private var difficultyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Difficulty")
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

    private var timerSurface: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Countdown")
                .productivityBodyStyle()
            ProgressView(
                value: max(viewModel.remainingTime, 0),
                total: productivity.difficultyTier.workflowTimeLimit
            )
            .tint(Color.appAccent)

            Text(timeLabel)
                .productivityCaptionStyle()

            Text("Attempts remaining: \(viewModel.livesRemaining)")
                .productivityCaptionStyle()
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private var timeLabel: String {
        let remaining = max(viewModel.remainingTime, 0)
        let seconds = Int(ceil(remaining))
        return "Seconds remaining: \(seconds)"
    }

    private var benchmarkSurface: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Benchmark Order")
                .productivityBodyStyle()

            HStack(spacing: 8) {
                ForEach(Array(viewModel.benchmarkOrder.enumerated()), id: \.offset) { _, value in
                    Text(shortTitle(for: value))
                        .productivityCaptionStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.appAccent.opacity(0.62),
                                            Color.appPrimary.opacity(0.42)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                                }
                                .shadow(color: Color.black.opacity(0.22), radius: 5, x: 0, y: 3)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(16)
        .productivityInsetPanel(cornerRadius: 18)
    }

    private func shortTitle(for index: Int) -> String {
        guard viewModel.labels.indices.contains(index) else {
            return "#\(index + 1)"
        }
        let title = viewModel.labels[index]
        if title.count <= 10 {
            return title
        }
        return String(title.prefix(9)) + "…"
    }

    private var controlsSurface: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions")
                .productivityBodyStyle()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(viewModel.labels.indices, id: \.self) { index in
                    Button {
                        ProductivityFeedback.light()
                        viewModel.handleTap(step: index)
                    } label: {
                        Text(viewModel.labels[index])
                            .productivityBodyStyle()
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .productivitySecondaryPlate(cornerRadius: 14)
                    }
                    .buttonStyle(ScalePressButtonStyle(scale: 0.96))
                }
            }

            Text(progressLabel)
                .productivityCaptionStyle()
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private var progressLabel: String {
        "Benchmark match: \(viewModel.benchmarkMatchPercent())%"
    }

    private func manualFinalize() {
        viewModel.forceFinish()
    }

    private func emitResult() {
        guard emitted == false else { return }
        emitted = true

        let stars = viewModel.starCount()
        let percent = viewModel.benchmarkMatchPercent()
        let rate = viewModel.completionRate()
        result = ActivityResultPayload(
            activity: .workflowChallenge,
            level: levelIndex,
            stars: stars,
            streakLength: productivity.dailyStreaks,
            benchmarkPercent: percent,
            completionRate: rate,
            momentumSnapshot: nil
        )
    }
}
