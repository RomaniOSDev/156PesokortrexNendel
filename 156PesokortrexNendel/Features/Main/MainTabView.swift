//
//  MainTabView.swift
//  156PesokortrexNendel
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var tabRouter: TabRouter

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tabRouter.selectedTab {
                case 0:
                    HomeView()
                case 1:
                    DashboardView()
                case 2:
                    AnalyticsView()
                default:
                    EfficiencyPlannerView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .productivityScreenBackdrop()

            CustomTabBar(selection: $tabRouter.selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }
    }
}

private struct CustomTabBar: View {
    @Binding var selection: Int

    private let items: [(title: String, index: Int)] = [
        ("Home", 0),
        ("Dashboard", 1),
        ("Analytics", 2),
        ("Planner", 3)
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(items, id: \.index) { item in
                Button {
                    ProductivityFeedback.light()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selection = item.index
                    }
                } label: {
                    Text(item.title)
                        .productivityCaptionStyle()
                        .foregroundStyle(selection == item.index ? Color.appTextPrimary : Color.appTextSecondary)
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .productivitySelectableFill(isSelected: selection == item.index, cornerRadius: 14)
                }
                .buttonStyle(ScalePressButtonStyle(scale: 0.96))
                .accessibilityLabel(Text(item.title))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.96),
                                Color.appSurface.opacity(0.74)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.14), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), Color.appAccent.opacity(0.32)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.38), radius: 22, y: 14)
        .shadow(color: Color.appPrimary.opacity(0.16), radius: 30, y: 18)
    }
}
