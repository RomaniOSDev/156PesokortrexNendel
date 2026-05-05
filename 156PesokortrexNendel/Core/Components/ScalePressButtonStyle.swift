//
//  ScalePressButtonStyle.swift
//  156PesokortrexNendel
//

import SwiftUI

struct ScalePressButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}
