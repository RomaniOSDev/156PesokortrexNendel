//
//  DashboardRoute.swift
//  156PesokortrexNendel
//

import SwiftUI

enum DashboardRoute: Hashable {
    case activityLevels(ActivityKind)
    case session(ActivityKind, Int)
    case modules
    case settings
}
