//
//  GroupDetailViewModel.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class GroupDetailViewModel {
    var numberOfTeams: Int = 2
    var generationMode: TeamGenerationMode = .balanced
    var generatedTeams: [Team] = []
    var insufficientWomen: Bool = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addPlayer(name: String, gender: Gender, skillLevel: SkillLevel, position: PlayerPosition, to group: GroupGame) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        let player = Player(name: trimmedName, gender: gender, skillLevel: skillLevel, position: position)
        modelContext.insert(player)
        // Reatribui o array inteiro (não só o lado inverso `player.group`) — senão a UI
        // (@Bindable var group) não percebe a mudança até algo mais tocar uma propriedade
        // observável de `group`. Passa por uma variável local em vez de
        // `group.players = group.players + [player]`: ler e escrever `group.players` na
        // mesma expressão dispara um trap de exclusividade do Swift ("Simultaneous
        // accesses") em propriedades de relacionamento do SwiftData (que são @Observable).
        var updatedPlayers = group.players
        updatedPlayers.append(player)
        group.players = updatedPlayers
    }

    func deletePlayer(_ player: Player) {
        if let group = player.group {
            var updatedPlayers = group.players
            updatedPlayers.removeAll { $0.id == player.id }
            group.players = updatedPlayers
        }
        modelContext.delete(player)
    }

    /// Mantém `numberOfTeams` dentro do range válido pra quantidade de jogadores
    /// selecionados no momento — sem isso, um valor escolhido antes (ex: 12 times
    /// com 12 jogadores) sobrevive mesmo depois de excluir/desmarcar jogadores.
    func clampNumberOfTeams(selectedCount: Int) {
        numberOfTeams = min(numberOfTeams, max(2, selectedCount))
    }

    func canGenerateTeams(selectedCount: Int) -> Bool {
        selectedCount >= numberOfTeams
    }

    func generateTeams(for group: GroupGame) {
        let result = TeamGeneratorService.generateTeams(
            from: group.players,
            numberOfTeams: numberOfTeams,
            minWomenPerTeam: group.minWomenPerTeam,
            mode: generationMode
        )
        generatedTeams = result.teams
        insufficientWomen = result.insufficientWomen
    }
}
