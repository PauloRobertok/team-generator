//
//  MatchQueueEngine.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 18/08/26.
//

import Foundation

/// Motor puro (sem SwiftUI/SwiftData) da fila de confronto ao vivo — quem joga contra
/// quem, na ordem certa, conforme a `MatchRotationRule` do grupo.
///
/// `.sequential`: quem vence fica na quadra, só o desafiante da frente da fila entra.
///
/// `.winStreakExit` (só ativa com mais de 3 times no total — com 3 ou menos funciona
/// como `.sequential`): vencer 2 confrontos seguidos tira o time da quadra mesmo tendo
/// vencido — ele volta pra fila na frente de todo mundo, exceto os dois times que já
/// foram escalados pro confronto seguinte. Isso dá mais dinâmica pra sessões com muita
/// gente de fora esperando, sem deixar o mesmo time dominando a quadra indefinidamente.
struct MatchQueueEngine {
    struct TeamStats {
        var matchesPlayed = 0
        var matchesWon = 0
        var totalPoints = 0
    }

    struct MatchOutcome {
        let winner: Team
        let loser: Team
        let winnerExited: Bool
    }

    /// Retrato de um confronto já decidido — pra guardar no histórico depois, já que o
    /// motor em si (e `stats`) só mantém o total agregado.
    struct MatchRecord: Codable, Identifiable {
        var id = UUID()
        var teamAName: String
        var teamBName: String
        var scoreA: Int
        var scoreB: Int
        var winnerName: String
    }

    enum RecordError: Error {
        case tie
    }

    private(set) var court: (teamA: Team, teamB: Team)
    private(set) var queue: [Team]
    private(set) var stats: [UUID: TeamStats]
    private(set) var matchLog: [MatchRecord] = []

    private var streaks: [UUID: Int] = [:]
    private let rule: MatchRotationRule
    private let totalTeams: Int

    init(teams: [Team], rule: MatchRotationRule) {
        precondition(teams.count >= 2, "Precisa de pelo menos 2 times pra iniciar um confronto")
        self.totalTeams = teams.count
        self.court = (teams[0], teams[1])
        self.queue = Array(teams.dropFirst(2))
        self.rule = rule
        self.stats = Dictionary(uniqueKeysWithValues: teams.map { ($0.id, TeamStats()) })
    }

    @discardableResult
    mutating func recordResult(scoreA: Int, scoreB: Int) throws -> MatchOutcome {
        guard scoreA != scoreB else { throw RecordError.tie }

        let winner = scoreA > scoreB ? court.teamA : court.teamB
        let loser = scoreA > scoreB ? court.teamB : court.teamA
        let winnerScore = max(scoreA, scoreB)
        let loserScore = min(scoreA, scoreB)

        stats[winner.id, default: TeamStats()].matchesPlayed += 1
        stats[winner.id, default: TeamStats()].matchesWon += 1
        stats[winner.id, default: TeamStats()].totalPoints += winnerScore
        stats[loser.id, default: TeamStats()].matchesPlayed += 1
        stats[loser.id, default: TeamStats()].totalPoints += loserScore

        matchLog.append(MatchRecord(
            teamAName: court.teamA.name,
            teamBName: court.teamB.name,
            scoreA: scoreA,
            scoreB: scoreB,
            winnerName: winner.name
        ))

        streaks[loser.id] = 0
        queue.append(loser)

        let winnerStreak = (streaks[winner.id] ?? 0) + 1
        let winnerExited = rule == .winStreakExit && totalTeams > 3 && winnerStreak == 2

        if winnerExited {
            streaks[winner.id] = 0
            let newA = queue.removeFirst()
            let newB = queue.removeFirst()
            queue.insert(winner, at: 0)
            court = (newA, newB)
        } else {
            streaks[winner.id] = winnerStreak
            let challenger = queue.removeFirst()
            court = (winner, challenger)
        }

        return MatchOutcome(winner: winner, loser: loser, winnerExited: winnerExited)
    }
}
