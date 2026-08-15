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
    /// num único pool guloso por skill. Se `minWomenPerTeam > 0`, reserva esse mínimo de
    /// mulheres por time (também balanceado) e distribui o restante — homens + mulheres
    /// excedentes — junto, continuando o mesmo balanceamento.
    ///
    /// Balancear em grupos de tamanhos variados pra minimizar a diferença de skill médio
    /// entre times é um problema combinatório sem solução exata "de uma passada só" — a
    /// abordagem aqui é gulosa (sempre manda o próximo jogador pro time mais carente) e
    /// depois roda um refinamento local trocando pares de jogadores entre o time mais
    /// forte e o mais fraco sempre que isso reduzir a diferença.
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
        let mustRespectGender: Bool

        if minWomenPerTeam > 0 {
            let females = selectedPlayers
                .filter { $0.gender == .female }
                .sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
            let males = selectedPlayers.filter { $0.gender == .male }

            let reservedCount = min(females.count, numberOfTeams * minWomenPerTeam)
            let reservedWomen = Array(females.prefix(reservedCount))
            let remainingWomen = Array(females.suffix(from: reservedCount))

            greedyDistribute(reservedWomen, into: &teams)

            let remainderPool = (remainingWomen + males).sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
            greedyDistribute(remainderPool, into: &teams)

            mustRespectGender = true
        } else {
            let pool = selectedPlayers.sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
            greedyDistribute(pool, into: &teams)
            mustRespectGender = false
        }

        refineBalance(&teams, respectGender: mustRespectGender)

        let femaleCount = selectedPlayers.filter { $0.gender == .female }.count
        let insufficientWomen = minWomenPerTeam > 0 && femaleCount < numberOfTeams * minWomenPerTeam
        return TeamGenerationResult(teams: teams, insufficientWomen: insufficientWomen)
    }

    /// Distribui `pool` (já ordenado por prioridade) entre os `teams`: a cada jogador,
    /// escolhe o time com menos jogadores até agora (e, empatado, o de menor soma de
    /// skill) — assim quem "sobra" quando a divisão não é exata vai justamente pro time
    /// mais carente, não pro mesmo time sempre.
    private static func greedyDistribute(_ pool: [Player], into teams: inout [Team]) {
        guard !pool.isEmpty, !teams.isEmpty else { return }

        for player in pool {
            let targetIndex = teams.indices.min { lhs, rhs in
                let lhsCount = teams[lhs].players.count
                let rhsCount = teams[rhs].players.count
                if lhsCount != rhsCount { return lhsCount < rhsCount }

                let lhsSum = teams[lhs].players.reduce(0) { $0 + $1.skillLevel.rawValue }
                let rhsSum = teams[rhs].players.reduce(0) { $0 + $1.skillLevel.rawValue }
                return lhsSum < rhsSum
            }!

            teams[targetIndex].players.append(player)
        }
    }

    /// Refinamento local: enquanto existir uma troca de um jogador do time de skill médio
    /// mais alto por um do time mais baixo (mesmo gênero, se `respectGender`) que reduza a
    /// diferença entre os dois, aplica a melhor troca encontrada. Repete até não achar mais
    /// nenhuma que ajude, ou até o limite de iterações.
    private static func refineBalance(_ teams: inout [Team], respectGender: Bool, maxIterations: Int = 200) {
        guard teams.count > 1 else { return }

        for _ in 0..<maxIterations {
            guard
                let highIndex = teams.indices.max(by: { teams[$0].averageSkill < teams[$1].averageSkill }),
                let lowIndex = teams.indices.min(by: { teams[$0].averageSkill < teams[$1].averageSkill }),
                highIndex != lowIndex
            else { break }

            let currentGap = teams[highIndex].averageSkill - teams[lowIndex].averageSkill
            guard currentGap > 0.01 else { break }

            var bestSwap: (highPlayerIndex: Int, lowPlayerIndex: Int, resultingGap: Double)?

            for (hi, highPlayer) in teams[highIndex].players.enumerated() {
                for (li, lowPlayer) in teams[lowIndex].players.enumerated() {
                    if respectGender && highPlayer.gender != lowPlayer.gender { continue }
                    guard highPlayer.skillLevel.rawValue != lowPlayer.skillLevel.rawValue else { continue }

                    var trialHigh = teams[highIndex]
                    var trialLow = teams[lowIndex]
                    trialHigh.players[hi] = lowPlayer
                    trialLow.players[li] = highPlayer

                    let resultingGap = abs(trialHigh.averageSkill - trialLow.averageSkill)
                    if resultingGap < currentGap - 0.001, (bestSwap == nil || resultingGap < bestSwap!.resultingGap) {
                        bestSwap = (hi, li, resultingGap)
                    }
                }
            }

            guard let swap = bestSwap else { break }

            let highPlayer = teams[highIndex].players[swap.highPlayerIndex]
            let lowPlayer = teams[lowIndex].players[swap.lowPlayerIndex]
            teams[highIndex].players[swap.highPlayerIndex] = lowPlayer
            teams[lowIndex].players[swap.lowPlayerIndex] = highPlayer
        }
    }
}
