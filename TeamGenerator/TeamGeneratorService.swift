//
//  TeamGeneratorService.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Foundation

struct TeamGenerationResult {
    var teams: [Team]
    var insufficientWomen: Bool
}

enum TeamGeneratorService {
    /// Distribui jogadores selecionados em `numberOfTeams` times: mulheres em round-robin
    /// (priorizando cobrir `minWomenPerTeam` por time) e homens em zig-zag por skill,
    /// pra equilibrar o nível entre os times.
    static func generateTeams(
        from players: [Player],
        numberOfTeams: Int,
        minWomenPerTeam: Int
    ) -> TeamGenerationResult {
        guard numberOfTeams >= 1 else {
            return TeamGenerationResult(teams: [], insufficientWomen: false)
        }

        let selectedPlayers = players.filter { $0.isSelected }
        let females = selectedPlayers
            .filter { $0.gender == .female }
            .sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
        let males = selectedPlayers
            .filter { $0.gender == .male }
            .sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }

        var teams = (1...numberOfTeams).map { Team(name: "Time \($0)", players: []) }

        for (index, female) in females.enumerated() {
            let teamIndex = index % numberOfTeams
            teams[teamIndex].players.append(female)
        }

        var currentTeamIndex = 0
        var direction = 1

        for male in males {
            teams[currentTeamIndex].players.append(male)

            currentTeamIndex += direction

            if currentTeamIndex >= numberOfTeams {
                currentTeamIndex = numberOfTeams - 1
                direction = -1
            } else if currentTeamIndex < 0 {
                currentTeamIndex = 0
                direction = 1
            }
        }

        let insufficientWomen = females.count < numberOfTeams * minWomenPerTeam
        return TeamGenerationResult(teams: teams, insufficientWomen: insufficientWomen)
    }
}
