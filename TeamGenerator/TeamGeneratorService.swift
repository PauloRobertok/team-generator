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
    /// Distribui jogadores selecionados em `numberOfTeams` times, equilibrando por skill.
    ///
    /// Se `minWomenPerTeam == 0`, gênero é ignorado e todos os jogadores entram juntos
    /// num único zig-zag por skill. Se `minWomenPerTeam > 0`, reserva esse mínimo de
    /// mulheres por time (também balanceado por skill) e distribui o restante — homens +
    /// mulheres excedentes — junto, num segundo zig-zag por skill.
    static func generateTeams(
        from players: [Player],
        numberOfTeams: Int,
        minWomenPerTeam: Int
    ) -> TeamGenerationResult {
        guard numberOfTeams >= 1 else {
            return TeamGenerationResult(teams: [], insufficientWomen: false)
        }

        let selectedPlayers = players.filter { $0.isSelected }
        var teams = (1...numberOfTeams).map { Team(name: "Time \($0)", players: []) }

        guard minWomenPerTeam > 0 else {
            let pool = selectedPlayers.sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
            zigZagDistribute(pool, into: &teams)
            return TeamGenerationResult(teams: teams, insufficientWomen: false)
        }

        let females = selectedPlayers
            .filter { $0.gender == .female }
            .sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
        let males = selectedPlayers.filter { $0.gender == .male }

        let reservedCount = min(females.count, numberOfTeams * minWomenPerTeam)
        let reservedWomen = Array(females.prefix(reservedCount))
        let remainingWomen = Array(females.suffix(from: reservedCount))

        // Continua a cauda-de-cobra de onde a primeira passada parou, em vez de
        // reiniciar do time 1 — senão o time 1 sempre levaria o "melhor" das duas
        // passadas.
        let stateAfterWomen = zigZagDistribute(reservedWomen, into: &teams)

        let remainderPool = (remainingWomen + males).sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
        zigZagDistribute(remainderPool, into: &teams, startIndex: stateAfterWomen.index, startDirection: stateAfterWomen.direction)

        let insufficientWomen = females.count < numberOfTeams * minWomenPerTeam
        return TeamGenerationResult(teams: teams, insufficientWomen: insufficientWomen)
    }

    /// Distribui `pool` (já ordenado por prioridade) em cauda-de-cobra entre os `teams`,
    /// pra equilibrar: 1º melhor pro time 1, 2º melhor pro time 2... e quando chega no
    /// fim volta na ordem inversa, em vez de recomeçar do time 1 sempre. Retorna onde a
    /// cauda parou, pra uma próxima chamada poder continuar dali.
    @discardableResult
    private static func zigZagDistribute(
        _ pool: [Player],
        into teams: inout [Team],
        startIndex: Int = 0,
        startDirection: Int = 1
    ) -> (index: Int, direction: Int) {
        guard !pool.isEmpty, !teams.isEmpty else { return (startIndex, startDirection) }

        var currentTeamIndex = startIndex
        var direction = startDirection

        for player in pool {
            teams[currentTeamIndex].players.append(player)

            currentTeamIndex += direction

            if currentTeamIndex >= teams.count {
                currentTeamIndex = teams.count - 1
                direction = -1
            } else if currentTeamIndex < 0 {
                currentTeamIndex = 0
                direction = 1
            }
        }

        return (currentTeamIndex, direction)
    }
}
