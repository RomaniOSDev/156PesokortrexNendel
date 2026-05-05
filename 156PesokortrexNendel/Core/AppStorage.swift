//
//  AppStorage.swift
//  156PesokortrexNendel
//

import Combine
import SwiftUI

extension Notification.Name {
    static let productivityDataDidReset = Notification.Name("productivityDataDidReset")
    static let resetDashboardNavigation = Notification.Name("resetDashboardNavigation")
}

enum DifficultyTier: Int, CaseIterable, Identifiable {
    case easy = 0
    case medium = 1
    case hard = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var workflowTickSeconds: TimeInterval {
        switch self {
        case .easy: return 1.0
        case .medium: return 0.65
        case .hard: return 0.45
        }
    }

    var workflowStepCount: Int {
        switch self {
        case .easy: return 4
        case .medium: return 5
        case .hard: return 6
        }
    }

    var workflowTimeLimit: TimeInterval {
        switch self {
        case .easy: return 28
        case .medium: return 22
        case .hard: return 16
        }
    }

    var momentumStarThresholds: (twoStar: Int, threeStar: Int) {
        switch self {
        case .easy: return (3, 5)
        case .medium: return (4, 7)
        case .hard: return (5, 9)
        }
    }

    var processInitialOverlap: Int {
        switch self {
        case .easy: return 0
        case .medium: return 1
        case .hard: return 2
        }
    }

    var processNodeCount: Int {
        switch self {
        case .easy: return 6
        case .medium: return 8
        case .hard: return 9
        }
    }
}

enum ActivityKind: Int, CaseIterable, Identifiable {
    case processDissection = 0
    case momentumBuilder = 1
    case workflowChallenge = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .processDissection: return "Process Dissection"
        case .momentumBuilder: return "Momentum Builder"
        case .workflowChallenge: return "Workflow Challenge"
        }
    }

    var summary: String {
        switch self {
        case .processDissection:
            return "Reposition nodes to reduce overlaps and clarify sequence."
        case .momentumBuilder:
            return "Keep completion streaks steady with deliberate daily signals."
        case .workflowChallenge:
            return "Align steps quickly against a benchmark schedule."
        }
    }
}

enum AchievementID: String, CaseIterable {
    case firstCompletion = "first_completion"
    case tenStars = "ten_stars"
    case momentumFocus = "momentum_focus"
    case workflowPrecision = "workflow_precision"
}

final class ProductivityData: ObservableObject {
    static let taskCompletionKey = "task_completion_rates"
    static let streakCountKey = "streak_count"
    static let bottleneckKey = "identified_bottlenecks"

    private static let hasSeenOnboardingKey = "has_seen_onboarding"
    private static let starsGridKey = "stars_grid_v1"
    private static let sessionsKey = "sessions_completed_v1"
    private static let achievementsKey = "achievements_blob_v1"
    private static let difficultyKey = "difficulty_tier_v1"
    private static let plannerGoalsKey = "planner_goal_progress_v1"
    private static let momentumSnapshotKey = "momentum_snapshot_v1"

    @AppStorage(wrappedValue: false, ProductivityData.hasSeenOnboardingKey) var hasSeenOnboarding: Bool

    @AppStorage(wrappedValue: "[]", ProductivityData.taskCompletionKey) var taskCompletionRatesBlob: String

    @AppStorage(wrappedValue: 0, ProductivityData.streakCountKey) var dailyStreaks: Int

    @AppStorage(wrappedValue: 2, ProductivityData.bottleneckKey) var identifiedBottlenecks: Int

    @AppStorage(wrappedValue: "[[0,0,0],[0,0,0],[0,0,0]]", ProductivityData.starsGridKey) private var starsGridBlob: String

    @AppStorage(wrappedValue: 0, ProductivityData.sessionsKey) private var sessionsCompleted: Int

    @AppStorage(wrappedValue: "", ProductivityData.achievementsKey) private var achievementsBlob: String

    @AppStorage(wrappedValue: DifficultyTier.medium.rawValue, ProductivityData.difficultyKey) var difficultyTierRaw: Int

    @AppStorage(wrappedValue: "[0.35,0.5,0.42]", ProductivityData.plannerGoalsKey) private var plannerGoalsBlob: String

    @AppStorage(wrappedValue: "", ProductivityData.momentumSnapshotKey) private var momentumBlob: String

    var difficultyTier: DifficultyTier {
        get { DifficultyTier(rawValue: difficultyTierRaw) ?? .medium }
        set { difficultyTierRaw = newValue.rawValue }
    }

    var taskCompletionRates: [Double] {
        decode(blob: taskCompletionRatesBlob) ?? []
    }

    var plannerGoalProgress: [Double] {
        get { decode(blob: plannerGoalsBlob) ?? [0.35, 0.5, 0.42] }
        set {
            if let encoded = encode(newValue) {
                plannerGoalsBlob = encoded
                objectWillChange.send()
            }
        }
    }

    var hasUnlockedMilestone: Bool {
        achievementsList.isEmpty == false
    }

    private var achievementsList: [String] {
        achievementsBlob.split(separator: ",").map(String.init).filter { $0.isEmpty == false }
    }

    func stars(activity: ActivityKind, level: Int) -> Int {
        guard level >= 0, level < 3 else { return 0 }
        let grid = decodeStarsGrid()
        let row = activity.rawValue
        guard row < grid.count, level < grid[row].count else { return 0 }
        return grid[row][level]
    }

    func setStars(activity: ActivityKind, level: Int, stars: Int) {
        var grid = decodeStarsGrid()
        while grid.count <= activity.rawValue {
            grid.append([0, 0, 0])
        }
        while grid[activity.rawValue].count < 3 {
            grid[activity.rawValue].append(0)
        }
        grid[activity.rawValue][level] = max(grid[activity.rawValue][level], stars)
        if let encoded = encode(grid) {
            starsGridBlob = encoded
        }
        objectWillChange.send()
    }

    func isLevelUnlocked(activity: ActivityKind, level: Int) -> Bool {
        if level == 0 { return true }
        return stars(activity: activity, level: level - 1) >= 1
    }

    func totalStarsEarned() -> Int {
        decodeStarsGrid().flatMap { $0 }.reduce(0, +)
    }

    func sessionsFinishedCount() -> Int {
        sessionsCompleted
    }

    func updateTrackedStreak(_ value: Int) {
        dailyStreaks = max(dailyStreaks, value)
        objectWillChange.send()
    }

    func recordSessionCompletion(rate: Double, bottleneckDelta: Int, momentumSnapshot: [Bool]) {
        var rates = taskCompletionRates
        rates.append(rate)
        if rates.count > 24 {
            rates.removeFirst(rates.count - 24)
        }
        if let encodedRates = encode(rates) {
            taskCompletionRatesBlob = encodedRates
        }

        identifiedBottlenecks = max(0, identifiedBottlenecks + bottleneckDelta)
        sessionsCompleted += 1
        if let momentumEncoded = encode(momentumSnapshot) {
            momentumBlob = momentumEncoded
        }
        objectWillChange.send()
    }

    func momentumSavedDays() -> [Bool] {
        decode(blob: momentumBlob) ?? Array(repeating: false, count: 14)
    }

    func advancePlannerGoals(by delta: Double) {
        var goals = plannerGoalProgress
        for index in goals.indices {
            goals[index] = min(1.0, goals[index] + delta)
        }
        if let encoded = encode(goals) {
            plannerGoalsBlob = encoded
        }
        objectWillChange.send()
    }

    func adjustPlannerGoal(at index: Int, delta: Double) {
        var goals = plannerGoalProgress
        guard goals.indices.contains(index) else { return }
        goals[index] = min(1.0, max(0, goals[index] + delta))
        if let encoded = encode(goals) {
            plannerGoalsBlob = encoded
        }
        objectWillChange.send()
    }

    func evaluateNewAchievements(
        activity: ActivityKind,
        starsEarned _: Int,
        streakLength: Int,
        benchmarkPercent: Int
    ) -> AchievementID? {
        var set = Set(achievementsList)
        var newest: AchievementID?

        if sessionsCompleted >= 1,
           set.contains(AchievementID.firstCompletion.rawValue) == false {
            set.insert(AchievementID.firstCompletion.rawValue)
            newest = .firstCompletion
        }

        if totalStarsEarned() >= 10,
           set.contains(AchievementID.tenStars.rawValue) == false {
            set.insert(AchievementID.tenStars.rawValue)
            newest = .tenStars
        }

        if activity == .momentumBuilder, streakLength >= 7,
           set.contains(AchievementID.momentumFocus.rawValue) == false {
            set.insert(AchievementID.momentumFocus.rawValue)
            newest = .momentumFocus
        }

        if activity == .workflowChallenge, benchmarkPercent >= 92,
           set.contains(AchievementID.workflowPrecision.rawValue) == false {
            set.insert(AchievementID.workflowPrecision.rawValue)
            newest = .workflowPrecision
        }

        achievementsBlob = set.sorted().joined(separator: ",")
        objectWillChange.send()
        return newest
    }

    func achievementTitle(for id: AchievementID) -> String {
        switch id {
        case .firstCompletion:
            return "First Structured Session"
        case .tenStars:
            return "Ten-Star Momentum"
        case .momentumFocus:
            return "Seven-Day Focus"
        case .workflowPrecision:
            return "Benchmark Precision"
        }
    }

    func resetProgress() {
        hasSeenOnboarding = false
        taskCompletionRatesBlob = "[]"
        dailyStreaks = 0
        identifiedBottlenecks = 2
        starsGridBlob = "[[0,0,0],[0,0,0],[0,0,0]]"
        sessionsCompleted = 0
        achievementsBlob = ""
        difficultyTierRaw = DifficultyTier.medium.rawValue
        plannerGoalsBlob = "[0.35,0.5,0.42]"
        momentumBlob = encode(Array(repeating: false, count: 14)) ?? ""

        NotificationCenter.default.post(name: .productivityDataDidReset, object: nil)
        objectWillChange.send()
    }

    private func decodeStarsGrid() -> [[Int]] {
        decode(blob: starsGridBlob) ?? [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
    }

    private func encode<T: Encodable>(_ value: T) -> String? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func decode<T: Decodable>(blob: String) -> T? {
        guard let data = blob.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

final class TabRouter: ObservableObject {
    /// 0 Home, 1 Dashboard, 2 Analytics, 3 Planner
    @Published var selectedTab: Int = 0

    func openHome() {
        selectedTab = 0
    }

    func openPlanner() {
        selectedTab = 3
    }

    func openDashboard() {
        selectedTab = 1
    }

    func openAnalytics() {
        selectedTab = 2
    }
}
