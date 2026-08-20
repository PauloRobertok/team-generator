//
//  GameSessionTests.swift
//  teamgeneratorTests
//
//  Created by Paulo Roberto C. on 18/08/26.
//

import Testing
@testable import teamgenerator

struct GameSessionTests {

    @Test func storesSportAndStatusRoundTrip() {
        let session = GameSession(name: "Vôlei de Terça", sport: .volleyball, status: .completed)

        #expect(session.sport == .volleyball)
        #expect(session.status == .completed)

        session.status = .cancelled
        #expect(session.status == .cancelled)
        #expect(session.statusRaw == SessionStatus.cancelled.rawValue)
    }

    @Test func storesTeamResultSnapshotsInOrder() {
        let results = [
            TeamResultSnapshot(name: "Time 1", badgeName: "Power Hitters", matchesPlayed: 3, matchesWon: 2, totalPoints: 47, playerNames: ["Alex", "Sarah"]),
            TeamResultSnapshot(name: "Time 2", badgeName: "Rally Kings", matchesPlayed: 2, matchesWon: 1, totalPoints: 31)
        ]
        let session = GameSession(name: "Vôlei de Terça", sport: .volleyball, status: .completed, teamResults: results)

        #expect(session.teamResults.count == 2)
        #expect(session.teamResults[0].name == "Time 1")
        #expect(session.teamResults[0].matchesWon == 2)
        #expect(session.teamResults[0].playerNames == ["Alex", "Sarah"])
        #expect(session.teamResults[1].totalPoints == 31)
        #expect(session.teamResults[1].playerNames.isEmpty)
    }

    @Test func defaultsToNoTeamResultsWhenNotProvided() {
        let session = GameSession(name: "Sunday Hoops", sport: .basketball, status: .cancelled)

        #expect(session.teamResults.isEmpty)
        #expect(session.matchLog.isEmpty)
    }

    @Test func storesMatchLogInOrder() {
        let log = [
            MatchQueueEngine.MatchRecord(teamAName: "Time 1", teamBName: "Time 2", scoreA: 21, scoreB: 15, winnerName: "Time 1"),
            MatchQueueEngine.MatchRecord(teamAName: "Time 1", teamBName: "Time 3", scoreA: 18, scoreB: 21, winnerName: "Time 3")
        ]
        let session = GameSession(name: "Vôlei de Terça", sport: .volleyball, status: .completed, matchLog: log)

        #expect(session.matchLog.count == 2)
        #expect(session.matchLog[0].winnerName == "Time 1")
        #expect(session.matchLog[1].teamBName == "Time 3")
    }
}
