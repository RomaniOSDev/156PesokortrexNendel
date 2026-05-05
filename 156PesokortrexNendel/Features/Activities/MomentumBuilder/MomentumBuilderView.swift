//
//  MomentumBuilderView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct MomentumBuilderView: View {
    let levelIndex: Int
    @Binding var result: ActivityResultPayload?

    @EnvironmentObject private var productivity: ProductivityData
    @StateObject private var viewModel: MomentumBuilderViewModel

    init(levelIndex: Int, result: Binding<ActivityResultPayload?>) {
        self.levelIndex = levelIndex
        _result = result
        _viewModel = StateObject(
            wrappedValue: MomentumBuilderViewModel(difficulty: .medium, saved: Array(repeating: false, count: 14))
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Momentum Builder")
                    .productivityTitleStyle()

                Text("Tap days for instant updates or press and hold for a stronger pulse.")
                    .productivitySecondaryStyle()
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                difficultyPicker

                chartSection

                daysMatrix

                metricsRow

                Button(action: finalizeSession) {
                    Text("Finalize Session")
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
            viewModel.reload(difficulty: productivity.difficultyTier, saved: productivity.momentumSavedDays())
        }
        .onChange(of: productivity.difficultyTierRaw) { _, _ in
            viewModel.reload(difficulty: productivity.difficultyTier, saved: productivity.momentumSavedDays())
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

    private var chartSection: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.5), Color.appAccent.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appSurface.opacity(0.52),
                                        Color.appBackground.opacity(0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                Canvas { context, canvasSize in
                    let strideCount = max(viewModel.dayStatuses.count - 1, 1)
                    var path = Path()
                    for index in viewModel.dayStatuses.indices {
                        let x = CGFloat(index) / CGFloat(strideCount) * canvasSize.width
                        let baseline = canvasSize.height * 0.82
                        let activeLift = viewModel.dayStatuses[index] ? canvasSize.height * 0.42 : 0
                        let y = baseline - activeLift
                        let point = CGPoint(x: x, y: y)
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                    context.stroke(path, with: .color(Color.appAccent.opacity(0.95)), lineWidth: 3)

                    for index in viewModel.dayStatuses.indices {
                        let x = CGFloat(index) / CGFloat(strideCount) * canvasSize.width
                        let baseline = canvasSize.height * 0.82
                        let activeLift = viewModel.dayStatuses[index] ? canvasSize.height * 0.42 : 0
                        let y = baseline - activeLift
                        let dot = Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                        context.fill(dot, with: .color(Color.appPrimary.opacity(0.95)))
                    }
                }
                .padding(16)
            }
            .frame(width: size.width, height: size.height)
        }
        .frame(height: 220)
        .productivityInsetPanel(cornerRadius: 18)
    }

    private var daysMatrix: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
            ForEach(viewModel.dayStatuses.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    Text("D\(index + 1)")
                        .productivityCaptionStyle()
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            viewModel.dayStatuses[index]
                                ? LinearGradient(
                                    colors: [
                                        Color.appAccent.opacity(0.95),
                                        Color.appPrimary.opacity(0.55)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [
                                        Color.appSurface.opacity(0.72),
                                        Color.appBackground.opacity(0.4)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.appPrimary.opacity(viewModel.dayStatuses[index] ? 0.45 : 0.28),
                                            Color.white.opacity(0.06)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.22), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            ProductivityFeedback.light()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.toggleDay(at: index)
                            }
                        }
                        .onLongPressGesture(minimumDuration: 0.35) {
                            ProductivityFeedback.medium()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.toggleDay(at: index)
                            }
                        }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("Day \(index + 1)"))
                .accessibilityHint(Text("Tap to toggle, or long press for emphasis"))
            }
        }
        .padding(12)
        .productivityInsetPanel(cornerRadius: 18)
    }

    private var metricsRow: some View {
        HStack(spacing: 12) {
            metricBubble(title: "Streak", value: "\(viewModel.streakLengthDetermined())d")
            metricBubble(title: "Intensity", value: "\(Int(viewModel.completionRate() * 100))%")
            metricBubble(title: "Stars", value: "\(viewModel.starsGranted()) est.")
        }
    }

    private func metricBubble(title: String, value: String) -> some View {
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

    private func finalizeSession() {
        let stars = viewModel.starsGranted()
        let streak = viewModel.streakLengthDetermined()
        let rate = viewModel.completionRate()
        let benchmark = min(100, streak * 12 + Int(rate * 40))
        result = ActivityResultPayload(
            activity: .momentumBuilder,
            level: levelIndex,
            stars: stars,
            streakLength: streak,
            benchmarkPercent: benchmark,
            completionRate: rate,
            momentumSnapshot: viewModel.dayStatuses
        )
    }
}
