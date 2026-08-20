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
    var playerNames: [String] = []

    init(
        name: String,
        badgeName: String,
        matchesPlayed: Int,
        matchesWon: Int,
        totalPoints: Int,
        playerNames: [String] = []
    ) {
        self.name = name
        self.badgeName = badgeName
        self.matchesPlayed = matchesPlayed
        self.matchesWon = matchesWon
        self.totalPoints = totalPoints
        self.playerNames = playerNames
    }

    // Decoder próprio: sessões salvas antes de `playerNames` existir não têm essa chave
    // no JSON persistido, e o Decodable sintetizado do Swift NÃO preenche o valor padrão
    // pra chave ausente em propriedade não-opcional — só pra Optional. Sem isso, abrir o
    // Histórico com sessões antigas crasha ao decodificar `GameSession.teamResults`.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        badgeName = try container.decode(String.self, forKey: .badgeName)
        matchesPlayed = try container.decode(Int.self, forKey: .matchesPlayed)
        matchesWon = try container.decode(Int.self, forKey: .matchesWon)
        totalPoints = try container.decode(Int.self, forKey: .totalPoints)
        playerNames = try container.decodeIfPresent([String].self, forKey: .playerNames) ?? []
    }
}

@Model
final class GameSession {
    var id: UUID = UUID()
    var name: String = ""
    var sportRaw: String = SportType.volleyball.rawValue
    var date: Date = Date()
    var statusRaw: String = SessionStatus.completed.rawValue
    var teamResults: [TeamResultSnapshot] = []
    var matchLog: [MatchQueueEngine.MatchRecord] = []

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
        teamResults: [TeamResultSnapshot] = [],
        matchLog: [MatchQueueEngine.MatchRecord] = []
    ) {
        self.id = UUID()
        self.name = name
        self.sportRaw = sport.rawValue
        self.date = date
        self.statusRaw = status.rawValue
        self.teamResults = teamResults
        self.matchLog = matchLog
    }
}
