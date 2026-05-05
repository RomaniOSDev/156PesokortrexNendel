//
//  AnalyticsView.swift
//  156PesokortrexNendel
//

import Combine
import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject private var productivity: ProductivityData
    @State private var selectedMetric: InsightMetric = .completion
    @State private var historySpan: Double = 1.0
    @State private var ringFocusIndex: Int = 0

    private let ringLabels = ["Deep Work", "Alignment", "QA"]

    enum InsightMetric: String, CaseIterable, Identifiable {
        case completion = "Completion Mix"
        case bottlenecks = "Bottleneck Load"
        case streaks = "Cadence Focus"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Analytics")
                        .productivityTitleStyle()

                    Text("Tap tiles, drag the history slider, and inspect ring segments.")
                        .productivitySecondaryStyle()
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    metricPicker

                    barCanvas

                    ringCanvas

                    ringInspectorRow

                    detailSurface

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

    private var metricPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
            ForEach(InsightMetric.allCases) { metric in
                Button {
                    ProductivityFeedback.light()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMetric = metric
                    }
                } label: {
                    Text(metric.rawValue)
                        .productivityCaptionStyle()
                        .foregroundStyle(selectedMetric == metric ? Color.appTextPrimary : Color.appTextSecondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .productivitySelectableFill(isSelected: selectedMetric == metric, cornerRadius: 14)
                }
                .buttonStyle(ScalePressButtonStyle(scale: 0.97))
            }
        }
    }

    private var barCanvas: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Completion Curve")
                .productivityBodyStyle()

            Canvas { context, size in
                let samples = normalizedRates()
                guard samples.isEmpty == false else {
                    let baseline = Path(CGRect(x: 8, y: size.height * 0.55, width: size.width - 16, height: 2))
                    context.stroke(baseline, with: .color(Color.appSurface.opacity(0.45)), lineWidth: 2)
                    return
                }

                let step = (size.width - 24) / CGFloat(max(samples.count - 1, 1))
                var path = Path()
                for (index, value) in samples.enumerated() {
                    let x = 12 + CGFloat(index) * step
                    let y = size.height - CGFloat(value) * (size.height - 28) - 12
                    let point = CGPoint(x: x, y: y)
                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                    let circle = Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                    context.fill(circle, with: .color(Color.appAccent.opacity(0.95)))
                }
                context.stroke(path, with: .color(Color.appPrimary.opacity(0.85)), lineWidth: 3)
            }
            .frame(height: 220)
            .productivityInsetPanel(cornerRadius: 18)

            VStack(alignment: .leading, spacing: 10) {
                Text("Tail emphasis")
                    .productivityCaptionStyle()
                Slider(value: $historySpan, in: 0.2...1.0)
                    .tint(Color.appAccent)
                Text(historySliderCaption)
                    .productivityCaptionStyle()
            }
            .padding(.top, 4)
        }
    }

    private var historySliderCaption: String {
        let percent = Int(round(historySpan * 100))
        return "Emphasizes the latest \(percent)% of logged intensity samples."
    }

    private var ringCanvas: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal Coverage")
                .productivityBodyStyle()

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2 - 24
                let goals = productivity.plannerGoalProgress
                let segments = max(goals.count, 1)
                let wedge = (CGFloat.pi * 2) / CGFloat(segments)

                for index in goals.indices {
                    let focused = index == ringFocusIndex
                    let start = wedge * CGFloat(index) - CGFloat.pi / 2
                    let end = start + wedge * 0.92
                    var track = Path()
                    track.addArc(center: center, radius: radius, startAngle: .radians(Double(start)), endAngle: .radians(Double(end)), clockwise: false)
                    context.stroke(track, with: .color(Color.appSurface.opacity(focused ? 0.9 : 0.55)), lineWidth: focused ? 19 : 14)

                    let progress = CGFloat(max(0, min(goals[index], 1)))
                    var progressPath = Path()
                    let clampedEnd = start + (end - start) * progress
                    progressPath.addArc(center: center, radius: radius, startAngle: .radians(Double(start)), endAngle: .radians(Double(clampedEnd)), clockwise: false)
                    context.stroke(progressPath, with: .color(Color.appAccent.opacity(0.98)), lineWidth: focused ? 19 : 14)
                }

                let clampedFocus = min(ringFocusIndex, max(goals.count - 1, 0))
                let midAngle = wedge * CGFloat(clampedFocus) + wedge * 0.46 - CGFloat.pi / 2
                let knobPoint = CGPoint(x: center.x + cos(midAngle) * radius, y: center.y + sin(midAngle) * radius)
                let knob = Path(ellipseIn: CGRect(x: knobPoint.x - 10, y: knobPoint.y - 10, width: 20, height: 20))
                context.fill(knob, with: .color(Color.appPrimary.opacity(0.95)))
            }
            .frame(height: 240)
            .productivityInsetPanel(cornerRadius: 18)
        }
    }

    private var ringInspectorRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inspect segment")
                .productivityBodyStyle()

            Picker("Segment", selection: $ringFocusIndex) {
                ForEach(ringLabels.indices, id: \.self) { idx in
                    Text(ringLabels[idx])
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .tag(idx)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: ringFocusIndex) { _, _ in
                ProductivityFeedback.light()
            }

            Text(segmentDetailCaption)
                .productivitySecondaryStyle()
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private var segmentDetailCaption: String {
        let goals = productivity.plannerGoalProgress
        let safeIndex = min(ringFocusIndex, max(goals.count - 1, 0))
        let progress = goals.indices.contains(safeIndex) ? goals[safeIndex] : 0
        let label = ringLabels.indices.contains(safeIndex) ? ringLabels[safeIndex] : ringLabels[0]
        return "\(label) tracks at \(Int(progress * 100))% inside your planner stack."
    }

    private var detailSurface: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Insight")
                .productivityBodyStyle()
            Text(detailCopy)
                .productivitySecondaryStyle()
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .productivityDepthCard(cornerRadius: 18)
    }

    private var detailCopy: String {
        switch selectedMetric {
        case .completion:
            let rates = productivity.taskCompletionRates
            if rates.isEmpty {
                return "Complete an activity to populate completion analytics."
            }
            let latest = rates.suffix(4).reduce(0.0, +) / Double(min(rates.count, 4))
            return "Recent completion intensity averages \(Int(latest * 100))% across your latest sessions."
        case .bottlenecks:
            return "Identified bottlenecks sit at \(productivity.identifiedBottlenecks). Reduce overlaps in Process sessions to lower this count."
        case .streaks:
            return "Your tracked streak is \(productivity.dailyStreaks) days. Momentum Builder pushes this higher through deliberate daily confirmations."
        }
    }

    private func normalizedRates() -> [CGFloat] {
        let rates = productivity.taskCompletionRates.map { CGFloat($0) }
        guard rates.isEmpty == false else { return rates }
        if rates.count == 1 {
            return rates
        }
        let clampedSpan = max(0.2, min(historySpan, 1.0))
        let trimmed = Int(floor(Double(rates.count - 1) * (1.0 - clampedSpan)))
        let startIndex = min(max(trimmed, 0), rates.count - 1)
        return Array(rates[startIndex...])
    }
}
