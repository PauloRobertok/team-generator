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

    @Test func ignoresGenderWhenNoMinimumIsSet() {
        let players = [
            Player(name: "F1", gender: .female, skillLevel: .pro),
            Player(name: "M1", gender: .male, skillLevel: .pro),
            Player(name: "F2", gender: .female, skillLevel: .beginner),
            Player(name: "M2", gender: .male, skillLevel: .beginner)
        ]
        let result = TeamGeneratorService.generateTeams(from: players, numberOfTeams: 2, minWomenPerTeam: 0)

        let counts = result.teams.map { $0.players.count }
        #expect(counts == [2, 2])
        // Um .pro e um .beginner por time, independente do gênero.
        #expect(result.teams[0].averageSkill == result.teams[1].averageSkill)
    }

    @Test func mixesLeftoverWomenWithMenInRemainderPool() {
        let players = [
            Player(name: "F1", gender: .female, skillLevel: .pro),
            Player(name: "F2", gender: .female, skillLevel: .pro),
            Player(name: "F3", gender: .female, skillLevel: .pro),
            Player(name: "F4", gender: .female, skillLevel: .pro),
            Player(name: "M1", gender: .male, skillLevel: .beginner),
            Player(name: "M2", gender: .male, skillLevel: .beginner)
        ]
        // minWomenPerTeam = 1: só 1 mulher por time é reservada (2 no total);
        // as outras 2 mulheres entram no pool misto junto com os homens.
        let result = TeamGeneratorService.generateTeams(from: players, numberOfTeams: 2, minWomenPerTeam: 1)

        let counts = result.teams.map { $0.players.count }
        #expect(counts == [3, 3])
        #expect(result.teams[0].femaleCount == 2)
        #expect(result.teams[1].femaleCount == 2)
        #expect(result.insufficientWomen == false)
    }

    @Test func refinesBalanceForUnevenGroupSizes() {
        // 7 pessoas em 3 times cai numa divisão 3-2-2 — o cenário que expunha o viés
        // do zig-zag antigo (o time que sobrava sempre acabava com o skill mais baixo).
        let players = [
            Player(name: "P1", gender: .female, skillLevel: .pro),
            Player(name: "P2", gender: .female, skillLevel: .pro),
            Player(name: "P3", gender: .female, skillLevel: .expert),
            Player(name: "P4", gender: .female, skillLevel: .expert),
            Player(name: "P5", gender: .female, skillLevel: .advanced),
            Player(name: "P6", gender: .female, skillLevel: .beginner),
            Player(name: "P7", gender: .female, skillLevel: .beginner)
        ]
        let result = TeamGeneratorService.generateTeams(from: players, numberOfTeams: 3, minWomenPerTeam: 3)

        let averages = result.teams.map { $0.averageSkill }
        let gap = (averages.max() ?? 0) - (averages.min() ?? 0)
        #expect(gap <= 1.0)
    }

    @Test func refinementNeverBreaksTheWomenMinimum() {
        let players = [
            Player(name: "F1", gender: .female, skillLevel: .pro),
            Player(name: "F2", gender: .female, skillLevel: .beginner),
            Player(name: "M1", gender: .male, skillLevel: .pro),
            Player(name: "M2", gender: .male, skillLevel: .pro),
            Player(name: "M3", gender: .male, skillLevel: .beginner),
            Player(name: "M4", gender: .male, skillLevel: .beginner)
        ]
        let result = TeamGeneratorService.generateTeams(from: players, numberOfTeams: 2, minWomenPerTeam: 1)

        // O refinamento por troca só pode trocar jogadoras por jogadoras (mesmo gênero),
        // então a regra de mínimo continua valendo mesmo depois de otimizar o skill.
        #expect(result.teams[0].femaleCount == 1)
        #expect(result.teams[1].femaleCount == 1)
    }
}
