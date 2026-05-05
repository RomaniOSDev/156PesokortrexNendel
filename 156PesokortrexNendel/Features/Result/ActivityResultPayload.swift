//
//  ActivityResultPayload.swift
//  156PesokortrexNendel
//

import SwiftUI

struct ActivityResultPayload: Identifiable, Hashable {
    let activity: ActivityKind
    let level: Int
    let stars: Int
    let streakLength: Int
    let benchmarkPercent: Int
    let completionRate: Double
    let momentumSnapshot: [Bool]?

    var id: String {
        "\(activity.rawValue)-\(level)-\(stars)-\(benchmarkPercent)-\(streakLength)"
    }
}
