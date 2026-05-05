//
//  ProductivityVisualChrome.swift
//  156PesokortrexNendel
//

import SwiftUI

enum ProductivityVisualChrome {
    static let cardCorner: CGFloat = 18
    static let buttonCorner: CGFloat = 16
    static let chipCorner: CGFloat = 14

    static var screenGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appBackground,
                Color.appPrimary.opacity(0.11),
                Color.appBackground,
                Color.appAccent.opacity(0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var screenRadialGlow: RadialGradient {
        RadialGradient(
            colors: [
                Color.appAccent.opacity(0.14),
                Color.clear
            ],
            center: .topTrailing,
            startRadius: 20,
            endRadius: 420
        )
    }

    static var cardFaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface,
                Color.appSurface.opacity(0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardHighlightGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.16),
                Color.clear
            ],
            startPoint: .top,
            endPoint: UnitPoint(x: 0.5, y: 0.55)
        )
    }

    static var cardEdgeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.28),
                Color.appAccent.opacity(0.38),
                Color.appPrimary.opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appPrimary,
                Color.appPrimary.opacity(0.72),
                Color.appAccent.opacity(0.62)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var insetWellGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.black.opacity(0.32),
                Color.appSurface.opacity(0.38),
                Color.appBackground.opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// Full-screen ambient gradient behind scroll content.
    func productivityScreenBackdrop() -> some View {
        background {
            ZStack {
                ProductivityVisualChrome.screenGradient
                ProductivityVisualChrome.screenRadialGlow
            }
            .ignoresSafeArea()
        }
    }

    /// Raised card: subtle face gradient, top highlight, rim light, layered shadow.
    func productivityDepthCard(cornerRadius: CGFloat = ProductivityVisualChrome.cardCorner) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ProductivityVisualChrome.cardFaceGradient)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ProductivityVisualChrome.cardHighlightGradient)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(ProductivityVisualChrome.cardEdgeGradient, lineWidth: 1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.26), radius: 14, x: 0, y: 8)
        .shadow(color: Color.appPrimary.opacity(0.14), radius: 26, x: 0, y: 14)
    }

    /// Recessed panel for charts and canvases.
    func productivityInsetPanel(cornerRadius: CGFloat = ProductivityVisualChrome.cardCorner) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ProductivityVisualChrome.insetWellGradient)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.clear,
                                Color.black.opacity(0.35)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.45), radius: 10, x: 0, y: 6)
        .shadow(color: Color.white.opacity(0.06), radius: 1, x: 0, y: -1)
    }

    @ViewBuilder
    func productivitySelectableFill(isSelected: Bool, cornerRadius: CGFloat = ProductivityVisualChrome.chipCorner) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    isSelected
                        ? LinearGradient(
                            colors: [
                                Color.appPrimary,
                                Color.appPrimary.opacity(0.68),
                                Color.appAccent.opacity(0.58)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : ProductivityVisualChrome.cardFaceGradient
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            isSelected
                                ? LinearGradient(
                                    colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.appAccent.opacity(0.18)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: isSelected ? Color.appAccent.opacity(0.28) : Color.black.opacity(0.16),
                    radius: isSelected ? 12 : 6,
                    x: 0,
                    y: isSelected ? 6 : 3
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// Primary CTA fill (use instead of flat `Color.appPrimary` backgrounds).
    func productivityPrimaryButtonShape(cornerRadius: CGFloat = ProductivityVisualChrome.buttonCorner) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(ProductivityVisualChrome.primaryButtonGradient)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.38), Color.white.opacity(0.06)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.appAccent.opacity(0.38), radius: 12, x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.32), radius: 8, x: 0, y: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// Secondary filled control with border (e.g. Trim, outlined buttons).
    func productivitySecondaryPlate(cornerRadius: CGFloat = ProductivityVisualChrome.chipCorner) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.98),
                            Color.appSurface.opacity(0.72)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.55),
                                    Color.appAccent.opacity(0.35)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.18), radius: 5, x: 0, y: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// Compact metric tile inside dashboards.
    func productivityMetricBubble(cornerRadius: CGFloat = ProductivityVisualChrome.chipCorner) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appBackground.opacity(0.52),
                                Color.appBackground.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.22), radius: 5, x: 0, y: 3)
    }

    /// Outer glow for hero banners and floating surfaces.
    func productivityFloatingElevation(cornerRadius: CGFloat = ProductivityVisualChrome.cardCorner) -> some View {
        shadow(color: Color.appAccent.opacity(0.22), radius: 28, x: 0, y: 16)
            .shadow(color: Color.black.opacity(0.42), radius: 22, x: 0, y: 14)
    }
}
