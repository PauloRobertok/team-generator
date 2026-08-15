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
    var generatedTeams: [Team] = []
    var insufficientWomen: Bool = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addPlayer(name: String, gender: Gender, skillLevel: SkillLevel, to group: GroupGame) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        let player = Player(name: trimmedName, gender: gender, skillLevel: skillLevel)
        player.group = group
        modelContext.insert(player)
    }

    func deletePlayer(_ player: Player) {
        modelContext.delete(player)
    }

    func generateTeams(for group: GroupGame) {
        let result = TeamGeneratorService.generateTeams(
            from: group.players,
            numberOfTeams: numberOfTeams,
            minWomenPerTeam: group.minWomenPerTeam
        )
        generatedTeams = result.teams
        insufficientWomen = result.insufficientWomen
    }
}
