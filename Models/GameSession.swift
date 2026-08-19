//
//  GameSession.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 18/08/26.
//

import Foundation
import SwiftData

/// Retrato congelado de como um time saiu de uma sessão de confrontos — não é o `Team`
/// gerado (que é recalculado e nunca persistido), é só os números que importam pro
/// histórico.
struct TeamResultSnapshot: Codable {
    var name: String
    var badgeName: String
    var matchesPlayed: Int
    var matchesWon: Int
    var totalPoints: Int
}

@Model
final class GameSession {
    var id: UUID = UUID()
    var name: String = ""
    var sportRaw: String = SportType.volleyball.rawValue
    var date: Date = Date()
    var statusRaw: String = SessionStatus.completed.rawValue
    var teamResults: [TeamResultSnapshot] = []

    var sport: SportType {
        get { SportType(rawValue: sportRaw) ?? .custom }
        set { sportRaw = newValue.rawValue }
    }

    var status: SessionStatus {
        get { SessionStatus(rawValue: statusRaw) ?? .completed }
        set { statusRaw = newValue.rawValue }
    }

    init(
        name: String,
        sport: SportType,
        date: Date = Date(),
        status: SessionStatus,
        teamResults: [TeamResultSnapshot] = []
    ) {
        self.id = UUID()
        self.name = name
        self.sportRaw = sport.rawValue
        self.date = date
        self.statusRaw = status.rawValue
        self.teamResults = teamResults
    }
}
