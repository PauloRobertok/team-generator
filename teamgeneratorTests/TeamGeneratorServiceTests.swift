//
//  TeamGeneratorServiceTests.swift
//  teamgeneratorTests
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Testing
@testable import teamgenerator

struct TeamGeneratorServiceTests {

    @Test func returnsEmptyWhenNumberOfTeamsIsZero() {
        let players = [Player(name: "A", gender: .male, skillLevel: .beginner)]
        let result = TeamGeneratorService.generateTeams(from: players, numberOfTeams: 0, minWomenPerTeam: 0)

        #expect(result.teams.isEmpty)
        #expect(result.insufficientWomen == false)
    }

    @Test func ignoresUnselectedPlayers() {
        let selected = Player(name: "Selected", gender: .male, skillLevel: .beginner)
        let unselected = Player(name: "Unselected", gender: .male, skillLevel: .beginner, isSelected: false)
        let result = TeamGeneratorService.generateTeams(from: [selected, unselected], numberOfTeams: 1, minWomenPerTeam: 0)

        let allPlayers = result.teams.flatMap { $0.players }
        #expect(allPlayers.count == 1)
        #expect(allPlayers.first?.name == "Selected")
    }

    @Test func distributesWomenAcrossAllTeams() {
        let players = [
            Player(name: "F1", gender: .female, skillLevel: .beginner),
            Player(name: "F2", gender: .female, skillLevel: .beginner),
            Player(name: "F3", gender: .female, skillLevel: .beginner),
            Player(name: "F4", gender: .female, skillLevel: .beginner)
        ]
        let result = TeamGeneratorService.generateTeams(from: players, numberOfTeams: 2, minWomenPerTeam: 2)

        #expect(result.teams.count == 2)
        #expect(result.teams[0].femaleCount == 2)
        #expect(result.teams[1].femaleCount == 2)
        #expect(result.insufficientWomen == false)
    }

    @Test func flagsInsufficientWomen() {
        let players = [Player(name: "F1", gender: .female, skillLevel: .beginner)]
        let result = TeamGeneratorService.generateTeams(from: players, numberOfTeams: 2, minWomenPerTeam: 2)

        #expect(result.insufficientWomen == true)
    }

    @Test func balancesMalesByskillAcrossTeams() {
        let players = (1...4).map { Player(name: "M\($0)", gender: .male, skillLevel: .pro) }
        let result = TeamGeneratorService.generateTeams(from: players, numberOfTeams: 2, minWomenPerTeam: 0)

        let counts = result.teams.map { $0.players.count }
        #expect(counts == [2, 2])
    }
}
