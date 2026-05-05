//
//  ProcessDissectionView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct ProcessDissectionView: View {
    let levelIndex: Int
    @Binding var result: ActivityResultPayload?

    @EnvironmentObject private var productivity: ProductivityData
    @StateObject private var viewModel: ProcessDissectionViewModel
    @State private var highlightedSlot: Int?

    init(levelIndex: Int, result: Binding<ActivityResultPayload?>) {
        self.levelIndex = levelIndex
        _result = result
        _viewModel = StateObject(wrappedValue: ProcessDissectionViewModel(difficulty: .medium, levelIndex: levelIndex))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Process Dissection")
                    .productivityTitleStyle()

                Text("Tap any lane to spotlight it while you drag chips across the grid.")
                    .productivitySecondaryStyle()
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                difficultyPicker

                gridBoard

                horizontalPalette

                metricsRow

                Button(action: finalizeSession) {
                    Text("Finalize Layout")
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
        }
        .onChange(of: productivity.difficultyTierRaw) { _, _ in
            viewModel.reload(difficulty: productivity.difficultyTier, levelIndex: levelIndex)
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
            .accessibilityLabel(Text("Difficulty"))
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: viewModel.columns)
    }

    private var gridBoard: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<(viewModel.rows * viewModel.columns), id: \.self) { index in
                cell(for: index)
                    .frame(minHeight: 72)
            }
        }
        .padding(12)
        .productivityInsetPanel(cornerRadius: 20)
    }

    private func cell(for index: Int) -> some View {
        let nodesHere = viewModel.nodes.filter { $0.gridIndex == index }
        let isHighlighted = highlightedSlot == index
        return ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isHighlighted ? Color.appAccent : Color.appPrimary.opacity(0.35), lineWidth: isHighlighted ? 3 : 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appSurface.opacity(isHighlighted ? 0.68 : 0.42),
                                        Color.appBackground.opacity(isHighlighted ? 0.38 : 0.22)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                VStack(spacing: 6) {
                ForEach(nodesHere) { node in
                    Text(node.label)
                        .productivityCaptionStyle()
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.appAccent.opacity(0.92),
                                            Color.appAccent.opacity(0.65)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.appPrimary.opacity(0.55), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
                        .gesture(dragGesture(for: node, originIndex: index))
                }
            }
            .padding(6)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                ProductivityFeedback.light()
                withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                    highlightedSlot = highlightedSlot == index ? nil : index
                }
            }
        )
    }

    private func dragGesture(for node: ProcessGridNode, originIndex: Int) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onEnded { value in
                let column = originIndex % viewModel.columns
                let row = originIndex / viewModel.columns
                var targetColumn = column
                var targetRow = row

                if value.translation.width > 28 {
                    targetColumn = min(column + 1, viewModel.columns - 1)
                } else if value.translation.width < -28 {
                    targetColumn = max(column - 1, 0)
                }

                if value.translation.height > 28 {
                    targetRow = min(row + 1, viewModel.rows - 1)
                } else if value.translation.height < -28 {
                    targetRow = max(row - 1, 0)
                }

                let targetIndex = targetRow * viewModel.columns + targetColumn
                viewModel.assign(node: node.id, to: targetIndex)
                ProductivityFeedback.light()
            }
    }

    private var horizontalPalette: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Node Ribbon")
                .productivityBodyStyle()
            let rows = [GridItem(.flexible())]
            LazyHGrid(rows: rows, spacing: 10) {
                ForEach(viewModel.nodes) { node in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appBackground.opacity(0.62),
                                    Color.appSurface.opacity(0.38)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.appPrimary.opacity(0.28), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.22), radius: 4, x: 0, y: 2)
                        .overlay(
                            Text(node.label)
                                .productivityCaptionStyle()
                                .foregroundStyle(Color.appTextSecondary)
                                .padding(.horizontal, 12)
                        )
                        .frame(height: 36)
                }
            }
        }
        .padding(16)
        .productivityInsetPanel(cornerRadius: 18)
    }

    private var metricsRow: some View {
        HStack(spacing: 12) {
            metricBubble(title: "Overlaps", value: "\(viewModel.overlapPenalty())")
            metricBubble(title: "Sequence", value: viewModel.efficiencyBonus() == 1 ? "Aligned" : "Loose")
            metricBubble(title: "Stars", value: "\(viewModel.computedStars()) est.")
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
        ProductivityFeedback.success()
        let stars = viewModel.computedStars()
        let rate = viewModel.completionRate()
        let overlap = viewModel.overlapPenalty()
        let benchmark = min(100, max(0, 100 - overlap * 14 + viewModel.efficiencyBonus() * 8))
        result = ActivityResultPayload(
            activity: .processDissection,
            level: levelIndex,
            stars: stars,
            streakLength: productivity.dailyStreaks,
            benchmarkPercent: benchmark,
            completionRate: rate,
            momentumSnapshot: nil
        )
    }
}
