//
//  ProcessDissectionViewModel.swift
//  156PesokortrexNendel
//

import Combine
import SwiftUI

struct ProcessGridNode: Identifiable, Equatable {
    let id: UUID
    let label: String
    let priorityIndex: Int
    var gridIndex: Int
}

final class ProcessDissectionViewModel: ObservableObject {
    @Published private(set) var nodes: [ProcessGridNode] = []

    let rows = 3
    let columns = 4

    private var difficulty: DifficultyTier

    init(difficulty: DifficultyTier, levelIndex: Int) {
        self.difficulty = difficulty
        rebuild(levelIndex: levelIndex)
    }

    func reload(difficulty: DifficultyTier, levelIndex: Int) {
        self.difficulty = difficulty
        rebuild(levelIndex: levelIndex)
    }

    func rebuild(levelIndex: Int) {
        let count = min(difficulty.processNodeCount, 14)
        let templates = [
            "Scope", "Sketch", "Align", "Build", "Measure", "Sync",
            "Review", "Refine", "Deliver", "Checkpoint", "Focus", "Cluster",
            "Stream", "Align+"
        ]

        var built: [ProcessGridNode] = []
        for index in 0..<count {
            let label = templates[(index + levelIndex) % templates.count]
            built.append(
                ProcessGridNode(
                    id: UUID(),
                    label: label,
                    priorityIndex: index,
                    gridIndex: min(index, rows * columns - 1)
                )
            )
        }

        let overlapIterations = min(difficulty.processInitialOverlap, max(built.count - 1, 0))
        if overlapIterations > 0 {
            for index in 0..<overlapIterations {
                let anchor = index % built.count
                let target = built[anchor].gridIndex
                let victimIndex = (index + 1) % built.count
                built[victimIndex].gridIndex = target
            }
        }

        nodes = built
    }

    func assign(node id: UUID, to gridIndex: Int) {
        guard let nodeIndex = nodes.firstIndex(where: { $0.id == id }) else { return }
        let capped = min(max(gridIndex, 0), rows * columns - 1)
        nodes[nodeIndex].gridIndex = capped
    }

    func overlapPenalty() -> Int {
        var buckets = [Int: Int]()
        for node in nodes {
            buckets[node.gridIndex, default: 0] += 1
        }
        return buckets.values.reduce(0) { partial, value in
            partial + max(0, value - 1)
        }
    }

    func efficiencyBonus() -> Int {
        let orderedNodes = nodes.sorted { lhs, rhs in
            if lhs.gridIndex == rhs.gridIndex {
                return lhs.priorityIndex < rhs.priorityIndex
            }
            return lhs.gridIndex < rhs.gridIndex
        }
        let sequence = orderedNodes.map(\.priorityIndex)
        let sortedSequence = sequence.sorted()
        return sequence == sortedSequence ? 1 : 0
    }

    func computedStars() -> Int {
        let baseStars = 3
        let overlap = overlapPenalty()
        let bonus = efficiencyBonus()
        let score = baseStars - overlap + bonus
        return min(3, max(1, score))
    }

    func completionRate() -> Double {
        let overlap = overlapPenalty()
        let bonus = efficiencyBonus()
        let raw = 1.0 - Double(overlap) * 0.18 + Double(bonus) * 0.12 + 0.08
        return min(1.0, max(0.18, raw))
    }
}
