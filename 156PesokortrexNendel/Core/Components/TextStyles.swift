//
//  TextStyles.swift
//  156PesokortrexNendel
//

import SwiftUI

extension View {
    func productivityTitleStyle() -> some View {
        self.font(.title3.weight(.bold))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    func productivityBodyStyle() -> some View {
        self.font(.body.weight(.medium))
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    func productivitySecondaryStyle() -> some View {
        self.font(.footnote.weight(.semibold))
            .foregroundStyle(Color.appTextSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    func productivityCaptionStyle() -> some View {
        self.font(.caption.weight(.semibold))
            .foregroundStyle(Color.appTextSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}
