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
    /// Nomes cosméticos sorteados pros badges dos times — puramente visual, sem efeito no
    /// balanceamento.
    private static let badgeNames = [
        "Power Hitters", "Net Guards", "Ace Squad", "Block Party",
        "Spike Force", "Rally Kings", "Set Masters", "Court Crushers"
    ]
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
    ///
    /// Sempre que o algoritmo encontra mais de uma opção igualmente boa (times empatados
    /// em carência, trocas empatadas em quanto melhoram o equilíbrio), sorteia entre elas
    /// em vez de sempre pegar a primeira — senão a mesma entrada gera sempre exatamente o
    /// mesmo resultado, o que não parece um sorteio de verdade.
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
                .shuffled()
                .sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
            let males = selectedPlayers.filter { $0.gender == .male }

            let reservedCount = min(females.count, numberOfTeams * minWomenPerTeam)
            let reservedWomen = Array(females.prefix(reservedCount))
            let remainingWomen = Array(females.suffix(from: reservedCount))

            greedyDistribute(reservedWomen, into: &teams)

            let remainderPool = (remainingWomen + males)
                .shuffled()
                .sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
            greedyDistribute(remainderPool, into: &teams)

            mustRespectGender = true
        } else {
            let pool = selectedPlayers.shuffled().sorted { $0.skillLevel.rawValue > $1.skillLevel.rawValue }
            greedyDistribute(pool, into: &teams)
            mustRespectGender = false
        }

        refineBalance(&teams, respectGender: mustRespectGender)
        assignBadgeNames(&teams)

        let femaleCount = selectedPlayers.filter { $0.gender == .female }.count
        let insufficientWomen = minWomenPerTeam > 0 && femaleCount < numberOfTeams * minWomenPerTeam
        return TeamGenerationResult(teams: teams, insufficientWomen: insufficientWomen)
    }

    /// Distribui `pool` (já ordenado por prioridade) entre os `teams`: a cada jogador,
    /// escolhe o time com menos jogadores até agora (e, empatado, o de menor soma de
    /// skill) — assim quem "sobra" quando a divisão não é exata vai justamente pro time
    /// mais carente, não pro mesmo time sempre. Quando mais de um time empata em carência,
    /// sorteia entre os empatados.
    private static func greedyDistribute(_ pool: [Player], into teams: inout [Team]) {
        guard !pool.isEmpty, !teams.isEmpty else { return }

        for player in pool {
            let sums = teams.map { $0.players.reduce(0) { $0 + $1.skillLevel.rawValue } }
            let minCount = teams.map(\.players.count).min()!
            let candidates = teams.indices.filter { teams[$0].players.count == minCount }
            let minSum = candidates.map { sums[$0] }.min()!
            let tiedCandidates = candidates.filter { sums[$0] == minSum }

            let targetIndex = tiedCandidates.randomElement()!
            teams[targetIndex].players.append(player)
        }
    }

    private static func assignBadgeNames(_ teams: inout [Team]) {
        let shuffled = badgeNames.shuffled()
        for index in teams.indices {
            teams[index].badgeName = shuffled[index % shuffled.count]
        }
    }

    /// Refinamento local: enquanto existir uma troca de um jogador do time de skill médio
    /// mais alto por um do time mais baixo (mesmo gênero, se `respectGender`) que reduza a
    /// diferença entre os dois, aplica uma das melhores trocas encontradas (sorteando entre
    /// as empatadas). Repete até não achar mais nenhuma que ajude, ou até o limite de
    /// iterações.
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

            var candidateSwaps: [(highPlayerIndex: Int, lowPlayerIndex: Int, resultingGap: Double)] = []
            var bestGap = currentGap

            for (hi, highPlayer) in teams[highIndex].players.enumerated() {
                for (li, lowPlayer) in teams[lowIndex].players.enumerated() {
                    if respectGender && highPlayer.gender != lowPlayer.gender { continue }
                    guard highPlayer.skillLevel.rawValue != lowPlayer.skillLevel.rawValue else { continue }

                    var trialHigh = teams[highIndex]
                    var trialLow = teams[lowIndex]
                    trialHigh.players[hi] = lowPlayer
                    trialLow.players[li] = highPlayer

                    let resultingGap = abs(trialHigh.averageSkill - trialLow.averageSkill)
                    guard resultingGap < currentGap - 0.001 else { continue }

                    if resultingGap < bestGap - 0.001 {
                        bestGap = resultingGap
                        candidateSwaps = [(hi, li, resultingGap)]
                    } else if resultingGap < bestGap + 0.001 {
                        candidateSwaps.append((hi, li, resultingGap))
                    }
                }
            }

            guard let swap = candidateSwaps.randomElement() else { break }

            let highPlayer = teams[highIndex].players[swap.highPlayerIndex]
            let lowPlayer = teams[lowIndex].players[swap.lowPlayerIndex]
            teams[highIndex].players[swap.highPlayerIndex] = lowPlayer
            teams[lowIndex].players[swap.lowPlayerIndex] = highPlayer
        }
    }
}
