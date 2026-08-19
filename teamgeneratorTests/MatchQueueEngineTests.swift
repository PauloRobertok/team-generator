//
//  MatchQueueEngineTests.swift
//  teamgeneratorTests
//
//  Created by Paulo Roberto C. on 18/08/26.
//

import Testing
@testable import teamgenerator

struct MatchQueueEngineTests {

    private func makeTeams(_ count: Int) -> [Team] {
        (1...count).map { Team(name: "Time \($0)", players: []) }
    }

    @Test func sequentialRuleKeepsWinnerOnCourtAcrossMultipleWins() throws {
        let teams = makeTeams(4)
        var engine = MatchQueueEngine(teams: teams, rule: .sequential)

        let outcome1 = try engine.recordResult(scoreA: 21, scoreB: 15)
        #expect(outcome1.winnerExited == false)
        #expect(engine.court.teamA.id == teams[0].id)
        #expect(engine.court.teamB.id == teams[2].id)
        #expect(engine.queue.map(\.id) == [teams[3].id, teams[1].id])

        // Time 1 vence de novo — na regra sequenciada, mesmo 2 vitórias seguidas não tira
        // ninguém da quadra.
        let outcome2 = try engine.recordResult(scoreA: 21, scoreB: 10)
        #expect(outcome2.winnerExited == false)
        #expect(engine.court.teamA.id == teams[0].id)
    }

    @Test func winStreakExitTriggersOnSecondConsecutiveWinWithMoreThanThreeTeams() throws {
        let teams = makeTeams(4)
        var engine = MatchQueueEngine(teams: teams, rule: .winStreakExit)

        // Time 1 vence do Time 2, joga contra o Time 3.
        let outcome1 = try engine.recordResult(scoreA: 21, scoreB: 15)
        #expect(outcome1.winnerExited == false)
        #expect(engine.court.teamA.id == teams[0].id)
        #expect(engine.court.teamB.id == teams[2].id)

        // Time 1 vence de novo (2 seguidas) — sai mesmo tendo vencido, quadra vira 4x2,
        // e a fila fica [1, 3]: 1 na frente por prioridade, atrás só de quem já ia entrar.
        let outcome2 = try engine.recordResult(scoreA: 21, scoreB: 18)
        #expect(outcome2.winnerExited == true)
        #expect(engine.court.teamA.id == teams[3].id)
        #expect(engine.court.teamB.id == teams[1].id)
        #expect(engine.queue.map(\.id) == [teams[0].id, teams[2].id])
    }

    @Test func winStreakResetsAfterExitingAndNeedsTwoFreshWinsAgain() throws {
        let teams = makeTeams(4)
        var engine = MatchQueueEngine(teams: teams, rule: .winStreakExit)

        try engine.recordResult(scoreA: 21, scoreB: 15) // Time 1 vence do Time 2
        try engine.recordResult(scoreA: 21, scoreB: 18) // Time 1 vence do Time 3, sai com prioridade
        // Quadra agora é Time 4 x Time 2, fila é [Time 1, Time 3].

        let outcome3 = try engine.recordResult(scoreA: 21, scoreB: 19) // Time 4 vence
        #expect(outcome3.winnerExited == false)
        #expect(engine.court.teamB.id == teams[0].id) // desafiante é o Time 1, que tinha prioridade

        // Time 1 vence do Time 4 — é a primeira vitória do Time 1 desde que voltou, não a
        // segunda seguida, então não deveria sair de novo.
        let outcome4 = try engine.recordResult(scoreA: 15, scoreB: 21)
        #expect(outcome4.winnerExited == false)
    }

    @Test func winStreakExitNeverTriggersWithThreeOrFewerTeams() throws {
        let teams = makeTeams(3)
        var engine = MatchQueueEngine(teams: teams, rule: .winStreakExit)

        try engine.recordResult(scoreA: 21, scoreB: 15)
        let outcome = try engine.recordResult(scoreA: 21, scoreB: 10)

        #expect(outcome.winnerExited == false)
    }

    @Test func throwsOnTieAndLeavesStateUnchanged() {
        let teams = makeTeams(4)
        var engine = MatchQueueEngine(teams: teams, rule: .sequential)
        let courtBefore = engine.court

        #expect(throws: MatchQueueEngine.RecordError.self) {
            try engine.recordResult(scoreA: 10, scoreB: 10)
        }
        #expect(engine.court.teamA.id == courtBefore.teamA.id)
        #expect(engine.court.teamB.id == courtBefore.teamB.id)
    }

    @Test func tracksMatchesPlayedWonAndTotalPointsPerTeam() throws {
        let teams = makeTeams(4)
        var engine = MatchQueueEngine(teams: teams, rule: .sequential)

        try engine.recordResult(scoreA: 21, scoreB: 15) // Time 1 vence do Time 2
        try engine.recordResult(scoreA: 21, scoreB: 10) // Time 1 vence do Time 3

        let team1Stats = try #require(engine.stats[teams[0].id])
        #expect(team1Stats.matchesPlayed == 2)
        #expect(team1Stats.matchesWon == 2)
        #expect(team1Stats.totalPoints == 42)

        let team2Stats = try #require(engine.stats[teams[1].id])
        #expect(team2Stats.matchesPlayed == 1)
        #expect(team2Stats.matchesWon == 0)
        #expect(team2Stats.totalPoints == 15)
    }
}
