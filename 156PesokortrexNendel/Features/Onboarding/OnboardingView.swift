//
//  OnboardingView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompleted: Bool
    @State private var pageIndex = 0

    private let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            stepLabel: "Structure",
            symbolName: "rectangle.split.3x1.fill",
            title: "Dissect workflows into visible stages",
            subtitle: "Lay out stages to expose overlaps before they slow delivery.",
            illustration: .workflowLayers
        ),
        OnboardingPageModel(
            stepLabel: "Alignment",
            symbolName: "square.grid.3x3.fill",
            title: "Align tasks with strategic priorities",
            subtitle: "Keep contributors oriented toward outcomes that matter each week.",
            illustration: .alignmentGrid
        ),
        OnboardingPageModel(
            stepLabel: "Cadence",
            symbolName: "target",
            title: "Plan goals with measurable checkpoints",
            subtitle: "Translate ambition into weekly checkpoints you can actually monitor.",
            illustration: .goalOrbit
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $pageIndex) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, model in
                    OnboardingPageView(model: model, pageIndex: index, totalPages: pages.count)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            bottomChrome
        }
        .productivityScreenBackdrop()
    }

    private var bottomChrome: some View {
        VStack(spacing: 14) {
            OnboardingPagerDots(count: pages.count, selection: pageIndex)

            Button(action: advance) {
                Text(primaryButtonTitle)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .productivityPrimaryButtonShape(cornerRadius: 18)
            }
            .buttonStyle(ScalePressButtonStyle(scale: 0.98))
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity)
        .background {
            bottomChromeBackground
        }
    }

    private var bottomChromeBackground: some View {
        ZStack(alignment: .top) {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 28,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 28
                ),
                style: .continuous
            )
            .fill(
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(0.58),
                        Color.appBackground.opacity(0.94)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 28,
                        bottomLeading: 0,
                        bottomTrailing: 0,
                        topTrailing: 28
                    ),
                    style: .continuous
                )
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.appAccent.opacity(0.28),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
            .shadow(color: Color.black.opacity(0.38), radius: 28, y: -10)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 24)
        }
    }

    private var primaryButtonTitle: String {
        pageIndex >= pages.count - 1 ? "Get Started" : "Continue"
    }

    private func advance() {
        if pageIndex < pages.count - 1 {
            ProductivityFeedback.light()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                pageIndex += 1
            }
        } else {
            ProductivityFeedback.success()
            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                hasCompleted = true
            }
        }
    }
}

// MARK: - Models

private struct OnboardingPageModel {
    let stepLabel: String
    let symbolName: String
    let title: String
    let subtitle: String
    let illustration: OnboardingIllustrationKind
}

private enum OnboardingIllustrationKind {
    case workflowLayers
    case alignmentGrid
    case goalOrbit
}

// MARK: - Page

private struct OnboardingPageView: View {
    let model: OnboardingPageModel
    let pageIndex: Int
    let totalPages: Int

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                pageHeader

                Text(model.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 22)

                subtitleCard

                illustrationStage

                Spacer(minLength: 140)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }

    private var pageHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.55),
                                Color.appPrimary.opacity(0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    }
                    .shadow(color: Color.appAccent.opacity(0.35), radius: 12, x: 0, y: 6)

                Image(systemName: model.symbolName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary.opacity(0.95))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(model.stepLabel.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(Color.appAccent)

                Text("Step \(pageIndex + 1) of \(totalPages)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer(minLength: 0)
        }
    }

    private var subtitleCard: some View {
        Text(model.subtitle)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.appTextSecondary)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 14)
            .productivityDepthCard(cornerRadius: 18)
    }

    private var illustrationStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(0.14),
                            Color.appPrimary.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 300)
                .padding(.top, 24)
                .offset(y: 16)

            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                let phase = timeline.date.timeIntervalSinceReferenceDate
                illustrationCanvas(phase: phase)
                    .frame(height: 278)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.16),
                                        Color.appAccent.opacity(0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .productivityInsetPanel(cornerRadius: 22)
                    .productivityFloatingElevation(cornerRadius: 22)
            }
            .padding(.top, 28)
        }
    }

    private func illustrationCanvas(phase: Double) -> some View {
        Canvas { context, size in
            switch model.illustration {
            case .workflowLayers:
                drawWorkflowLayers(in: context, size: size, phase: phase)
            case .alignmentGrid:
                drawAlignmentGrid(in: context, size: size, phase: phase)
            case .goalOrbit:
                drawGoalOrbit(in: context, size: size, phase: phase)
            }
        }
        .background(Color.clear)
    }

    private func drawWorkflowLayers(in context: GraphicsContext, size: CGSize, phase: Double) {
        let pulse = 0.45 + 0.08 * sin(phase * 1.5)
        let layerHeight = size.height * 0.17
        for index in 0..<4 {
            let rect = CGRect(
                x: size.width * 0.07,
                y: CGFloat(index) * (layerHeight + 14) + 24,
                width: size.width * CGFloat(pulse + Double(index) * 0.045),
                height: layerHeight
            )
            let path = Path(roundedRect: rect, cornerRadius: 14)
            let layerOpacity = 0.72 - Double(index) * 0.09
            context.fill(path, with: .linearGradient(
                Gradient(colors: [
                    Color.appAccent.opacity(layerOpacity + 0.08),
                    Color.appPrimary.opacity(layerOpacity * 0.65)
                ]),
                startPoint: CGPoint(x: rect.minX, y: rect.minY),
                endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
            ))
            context.stroke(path, with: .color(Color.white.opacity(0.22)), lineWidth: 1)
            context.stroke(path, with: .color(Color.appPrimary.opacity(0.42)), lineWidth: 2)
        }
        let connector = Path { path in
            path.move(to: CGPoint(x: size.width * 0.54, y: size.height * 0.22))
            path.addQuadCurve(
                to: CGPoint(x: size.width * 0.84, y: size.height * 0.62),
                control: CGPoint(x: size.width * 0.72, y: size.height * 0.36 + CGFloat(sin(phase)) * 12)
            )
        }
        context.stroke(
            connector,
            with: .linearGradient(
                Gradient(colors: [Color.appAccent.opacity(0.85), Color.appPrimary.opacity(0.45)]),
                startPoint: CGPoint(x: size.width * 0.54, y: 0),
                endPoint: CGPoint(x: size.width * 0.9, y: size.height * 0.7)
            ),
            lineWidth: 3.5
        )
    }

    private func drawAlignmentGrid(in context: GraphicsContext, size: CGSize, phase: Double) {
        let spacing: CGFloat = 34
        let columns = max(Int(size.width / spacing), 2)
        let rows = max(Int(size.height / spacing), 2)
        for row in 0..<rows {
            for column in 0..<columns {
                let origin = CGPoint(x: CGFloat(column) * spacing + 16, y: CGFloat(row) * spacing + 18)
                let rect = CGRect(
                    x: origin.x,
                    y: origin.y,
                    width: spacing - 10,
                    height: spacing - 10
                )
                let shifted = rect.offsetBy(dx: CGFloat(sin(phase + Double(row + column))) * 4, dy: 0)
                let cell = Path(roundedRect: shifted, cornerRadius: 10)
                let active = (row + column) % 3 == 0
                if active {
                    context.fill(cell, with: .linearGradient(
                        Gradient(colors: [
                            Color.appAccent.opacity(0.82),
                            Color.appPrimary.opacity(0.52)
                        ]),
                        startPoint: CGPoint(x: shifted.minX, y: shifted.minY),
                        endPoint: CGPoint(x: shifted.maxX, y: shifted.maxY)
                    ))
                } else {
                    context.fill(cell, with: .linearGradient(
                        Gradient(colors: [
                            Color.appSurface.opacity(0.55),
                            Color.appBackground.opacity(0.35)
                        ]),
                        startPoint: CGPoint(x: shifted.midX, y: shifted.minY),
                        endPoint: CGPoint(x: shifted.midX, y: shifted.maxY)
                    ))
                }
                context.stroke(cell, with: .color(Color.white.opacity(0.1)), lineWidth: 1)
                context.stroke(cell, with: .color(Color.appPrimary.opacity(active ? 0.42 : 0.22)), lineWidth: 1.5)
            }
        }
    }

    private func drawGoalOrbit(in context: GraphicsContext, size: CGSize, phase: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let baseRadius = min(size.width, size.height) * 0.27
        for ring in 1...3 {
            let radius = baseRadius + CGFloat(ring) * 22 + CGFloat(sin(phase + Double(ring))) * 6
            let circle = Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
            context.stroke(
                circle,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.appAccent.opacity(0.72 - Double(ring) * 0.12),
                        Color.appPrimary.opacity(0.35)
                    ]),
                    startPoint: CGPoint(x: center.x - radius, y: center.y),
                    endPoint: CGPoint(x: center.x + radius, y: center.y)
                ),
                lineWidth: CGFloat(ring + 1)
            )
        }
        let core = Path(ellipseIn: CGRect(x: center.x - 24, y: center.y - 24, width: 48, height: 48))
        context.fill(core, with: .radialGradient(
            Gradient(colors: [
                Color.appPrimary.opacity(0.95),
                Color.appAccent.opacity(0.62)
            ]),
            center: center,
            startRadius: 0,
            endRadius: 28
        ))
        context.stroke(core, with: .color(Color.white.opacity(0.25)), lineWidth: 1)
        context.stroke(core, with: .color(Color.appAccent.opacity(0.55)), lineWidth: 2.5)

        let markerAngle = phase.truncatingRemainder(dividingBy: .pi * 2)
        let markerPoint = CGPoint(
            x: center.x + cos(markerAngle) * (baseRadius + 46),
            y: center.y + sin(markerAngle) * (baseRadius + 46)
        )
        let marker = Path(ellipseIn: CGRect(x: markerPoint.x - 9, y: markerPoint.y - 9, width: 18, height: 18))
        context.fill(marker, with: .radialGradient(
            Gradient(colors: [Color.appAccent.opacity(1), Color.appAccent.opacity(0.45)]),
            center: markerPoint,
            startRadius: 0,
            endRadius: 12
        ))
        context.stroke(marker, with: .color(Color.white.opacity(0.35)), lineWidth: 1)
    }
}

// MARK: - Pager

private struct OnboardingPagerDots: View {
    let count: Int
    let selection: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<count, id: \.self) { index in
                Group {
                    if index == selection {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appPrimary.opacity(0.75)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    } else {
                        Capsule()
                            .fill(Color.appSurface.opacity(0.55))
                    }
                }
                .frame(width: index == selection ? 28 : 8, height: 8)
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.white.opacity(index == selection ? 0.22 : 0.08), lineWidth: 1)
                    }
                    .shadow(
                        color: index == selection ? Color.appAccent.opacity(0.35) : Color.black.opacity(0.2),
                        radius: index == selection ? 8 : 3,
                        x: 0,
                        y: index == selection ? 4 : 2
                    )
                    .animation(.spring(response: 0.38, dampingFraction: 0.72), value: selection)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Page \(selection + 1) of \(count)"))
    }
}
