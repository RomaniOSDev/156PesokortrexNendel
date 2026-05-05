//
//  ActivitySessionCoordinator.swift
//  156PesokortrexNendel
//

import SwiftUI

struct ActivitySessionCoordinator: View {
    let activity: ActivityKind
    let level: Int

    @State private var resultPayload: ActivityResultPayload?

    var body: some View {
        Group {
            switch activity {
            case .processDissection:
                ProcessDissectionView(levelIndex: level, result: $resultPayload)
            case .momentumBuilder:
                MomentumBuilderView(levelIndex: level, result: $resultPayload)
            case .workflowChallenge:
                WorkflowChallengeView(levelIndex: level, result: $resultPayload)
            }
        }
        .navigationDestination(item: $resultPayload) { payload in
            ActivityResultView(payload: payload)
        }
    }
}
