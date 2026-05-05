//
//  MomentumBuilderViewModel.swift
//  156PesokortrexNendel
//

import Combine
import SwiftUI

final class MomentumBuilderViewModel: ObservableObject {
    @Published var dayStatuses: [Bool]

    private var difficulty: DifficultyTier

    init(difficulty: DifficultyTier, saved: [Bool]) {
        self.difficulty = difficulty
        if saved.count == 14 {
            self.dayStatuses = saved
        } else {
            self.dayStatuses = Array(repeating: false, count: 14)
        }
    }

    func reload(difficulty: DifficultyTier, saved: [Bool]) {
        self.difficulty = difficulty
        if saved.count == 14 {
            dayStatuses = saved
        } else {
            dayStatuses = Array(repeating: false, count: 14)
        }
    }

    func toggleDay(at index: Int) {
        guard dayStatuses.indices.contains(index) else { return }
        dayStatuses[index].toggle()
    }

    func streakLengthDetermined() -> Int {
        var streak = 0
        for index in (0..<14).reversed() {
            if dayStatuses[index] {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    func starsGranted() -> Int {
        let streak = streakLengthDetermined()
        let thresholds = difficulty.momentumStarThresholds
        if streak >= thresholds.threeStar {
            return 3
        }
        if streak >= thresholds.twoStar {
            return 2
        }
        return 1
    }

    func completionRate() -> Double {
        let activeDays = dayStatuses.filter { $0 }.count
        let streak = streakLengthDetermined()
        let blended = Double(activeDays) / 14.0 * 0.55 + Double(streak) / 12.0 * 0.45
        return min(1.0, max(0.2, blended))
    }
}
