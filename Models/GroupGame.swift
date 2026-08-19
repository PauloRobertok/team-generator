//
//  GroupGame.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Foundation
import SwiftData

@Model
final class GroupGame {
    var id: UUID = UUID()
    var name: String = ""
    var sportRaw: String = SportType.volleyball.rawValue
    var minWomenPerTeam: Int = 1
    var matchRotationRuleRaw: String = MatchRotationRule.sequential.rawValue
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Player.group)
    var players: [Player] = []

    var sport: SportType {
        get { SportType(rawValue: sportRaw) ?? .custom }
        set { sportRaw = newValue.rawValue }
    }

    var matchRotationRule: MatchRotationRule {
        get { MatchRotationRule(rawValue: matchRotationRuleRaw) ?? .sequential }
        set { matchRotationRuleRaw = newValue.rawValue }
    }

    init(name: String, sport: SportType, minWomenPerTeam: Int = 1, players: [Player] = []) {
        self.id = UUID()
        self.name = name
        self.sportRaw = sport.rawValue
        self.minWomenPerTeam = minWomenPerTeam
        self.createdAt = Date()
        self.players = players
    }
}
