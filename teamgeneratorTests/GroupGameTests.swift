//
//  GroupGameTests.swift
//  teamgeneratorTests
//
//  Created by Paulo Roberto C. on 18/08/26.
//

import Testing
@testable import teamgenerator

struct GroupGameTests {

    @Test func defaultsToSequentialMatchRotationRule() {
        let group = GroupGame(name: "Grupo", sport: .volleyball)

        #expect(group.matchRotationRule == .sequential)
    }

    @Test func matchRotationRuleRoundTrips() {
        let group = GroupGame(name: "Grupo", sport: .volleyball)

        group.matchRotationRule = .winStreakExit

        #expect(group.matchRotationRule == .winStreakExit)
        #expect(group.matchRotationRuleRaw == MatchRotationRule.winStreakExit.rawValue)
    }
}
