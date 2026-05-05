//
//  WorkflowChallengeViewModel.swift
//  156PesokortrexNendel
//

import Combine
import SwiftUI
import UIKit

final class WorkflowChallengeViewModel: ObservableObject {
    @Published var remainingTime: TimeInterval
    @Published var chosenSteps: [Int] = []
    @Published private(set) var benchmarkOrder: [Int]
    @Published private(set) var labels: [String]
    @Published var isFinished: Bool = false
    @Published private(set) var livesRemaining: Int

    private var difficulty: DifficultyTier
    private var cancellable: AnyCancellable?

    init(difficulty: DifficultyTier, levelIndex: Int) {
        self.difficulty = difficulty
        let count = difficulty.workflowStepCount
        let palette = [
            "Prioritize", "Sequence", "Allocate", "Verify", "Integrate", "Handoff",
            "QA Sweep", "Stakeholder Sync"
        ]
        self.labels = Array(palette.prefix(count))

        var base = Array(0..<count)
        let rotation = levelIndex % max(count, 1)
        if rotation > 0 {
            base = Array(base[rotation...] + base[..<rotation])
        }
        self.benchmarkOrder = base
        var initialTime = difficulty.workflowTimeLimit - Double(levelIndex) * 1.5
        if initialTime < 8 {
            initialTime = 8
        }
        self.remainingTime = initialTime
        self.livesRemaining = Self.livesCap(for: difficulty)
    }

    private static func livesCap(for difficulty: DifficultyTier) -> Int {
        switch difficulty {
        case .easy: return 5
        case .medium: return 3
        case .hard: return 2
        }
    }

    func reload(difficulty: DifficultyTier, levelIndex: Int) {
        stopTimer()
        chosenSteps = []
        isFinished = false
        self.difficulty = difficulty
        let count = difficulty.workflowStepCount
        let palette = [
            "Prioritize", "Sequence", "Allocate", "Verify", "Integrate", "Handoff",
            "QA Sweep", "Stakeholder Sync"
        ]
        labels = Array(palette.prefix(count))

        var base = Array(0..<count)
        let rotation = levelIndex % max(count, 1)
        if rotation > 0 {
            base = Array(base[rotation...] + base[..<rotation])
        }
        benchmarkOrder = base
        remainingTime = difficulty.workflowTimeLimit - Double(levelIndex) * 1.5
        if remainingTime < 8 {
            remainingTime = 8
        }
        livesRemaining = Self.livesCap(for: difficulty)
    }

    func startTimer() {
        cancellable?.cancel()
        cancellable = Timer.publish(every: difficulty.workflowTickSeconds, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard self.isFinished == false else { return }
                if self.remainingTime <= 0 {
                    self.finalizeDueToTimer()
                    return
                }
                self.remainingTime -= self.difficulty.workflowTickSeconds
                if self.remainingTime <= 0 {
                    self.finalizeDueToTimer()
                }
            }
    }

    func stopTimer() {
        cancellable?.cancel()
        cancellable = nil
    }

    func handleTap(step index: Int) {
        guard isFinished == false else { return }
        let nextPosition = chosenSteps.count
        guard nextPosition < benchmarkOrder.count else { return }

        if benchmarkOrder[nextPosition] == index {
            chosenSteps.append(index)
            if chosenSteps.count == benchmarkOrder.count {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                finalizeSuccess()
            }
        } else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.easeInOut(duration: 0.3)) {
                chosenSteps.removeAll()
            }
            if livesRemaining > 0 {
                livesRemaining -= 1
            }
            if livesRemaining <= 0 {
                forceFinish()
            }
        }
    }

    func benchmarkMatchPercent() -> Int {
        guard benchmarkOrder.isEmpty == false else { return 0 }
        let upperBound = min(chosenSteps.count, benchmarkOrder.count)
        if upperBound == 0 {
            return 0
        }
        var matches = 0
        for position in 0..<upperBound {
            if chosenSteps[position] == benchmarkOrder[position] {
                matches += 1
            }
        }
        return Int((Double(matches) / Double(benchmarkOrder.count)) * 100)
    }

    func starCount() -> Int {
        let percent = benchmarkMatchPercent()
        let completedAll = chosenSteps.count == benchmarkOrder.count && percent == 100
        if completedAll || percent >= 90 {
            return 3
        }
        if percent >= 70 {
            return 2
        }
        return 1
    }

    func completionRate() -> Double {
        let percent = Double(benchmarkMatchPercent()) / 100.0
        let timeRatio = min(1.0, max(remainingTime, 0) / max(difficulty.workflowTimeLimit, 1))
        return min(1.0, max(0.2, percent * 0.78 + timeRatio * 0.22))
    }

    private func finalizeSuccess() {
        guard isFinished == false else { return }
        isFinished = true
        stopTimer()
    }

    private func finalizeDueToTimer() {
        guard isFinished == false else { return }
        isFinished = true
        remainingTime = 0
        stopTimer()
    }

    func forceFinish() {
        guard isFinished == false else { return }
        stopTimer()
        isFinished = true
    }

    deinit {
        cancellable?.cancel()
    }
}
