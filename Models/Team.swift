//
//  Team.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Foundation

/// Time gerado pelo TeamGeneratorService. Não é persistido - é sempre
/// recalculado a partir dos jogadores selecionados de um GroupGame.
struct Team: Identifiable {
    var id: UUID = UUID()
    var name: String
    var players: [Player]
    var badgeName: String = ""

    var averageSkill: Double {
        guard !players.isEmpty else { return 0 }
        let total = players.reduce(0) { $0 + $1.skillLevel.rawValue }
        return Double(total) / Double(players.count)
    }

    var femaleCount: Int {
        players.filter { $0.gender == .female }.count
    }

    /// Jogador de maior skill do time — exibido com estrela de capitão.
    var captain: Player? {
        players.max { $0.skillLevel.rawValue < $1.skillLevel.rawValue }
    }
}
