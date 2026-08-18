//
//  GroupDetailViewModelTests.swift
//  teamgeneratorTests
//
//  Created by Paulo Roberto C. on 17/08/26.
//

import Testing
import SwiftData
@testable import teamgenerator

// Serializado: cada teste cria seu próprio ModelContainer in-memory, e criar
// vários em paralelo (comportamento padrão do Swift Testing) dispara um trap
// interno do SwiftData nesse simulator — não relacionado à lógica testada.
@Suite(.serialized)
@MainActor
struct GroupDetailViewModelTests {

    private func makeContext() -> ModelContext {
        let schema = Schema([GroupGame.self, Player.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }

    @Test func addPlayerUpdatesGroupPlayersImmediately() {
        let context = makeContext()
        let group = GroupGame(name: "Grupo", sport: .volleyball)
        context.insert(group)
        let viewModel = GroupDetailViewModel(modelContext: context)

        viewModel.addPlayer(name: "Nova", gender: .male, skillLevel: .beginner, position: .utility, to: group)

        #expect(group.players.count == 1)
        #expect(group.players.first?.name == "Nova")
    }

    @Test func deletePlayerUpdatesGroupPlayersImmediately() throws {
        let context = makeContext()
        let group = GroupGame(name: "Grupo", sport: .volleyball)
        context.insert(group)
        let viewModel = GroupDetailViewModel(modelContext: context)
        viewModel.addPlayer(name: "Sai", gender: .male, skillLevel: .beginner, position: .utility, to: group)
        #expect(group.players.count == 1)
        let player = try #require(group.players.first)

        viewModel.deletePlayer(player)

        #expect(group.players.isEmpty)
    }

    @Test func clampNumberOfTeamsReducesToSelectedCount() {
        let viewModel = GroupDetailViewModel(modelContext: makeContext())
        viewModel.numberOfTeams = 12

        viewModel.clampNumberOfTeams(selectedCount: 5)

        #expect(viewModel.numberOfTeams == 5)
    }

    @Test func clampNumberOfTeamsNeverGoesBelowTwo() {
        let viewModel = GroupDetailViewModel(modelContext: makeContext())
        viewModel.numberOfTeams = 6

        viewModel.clampNumberOfTeams(selectedCount: 1)

        #expect(viewModel.numberOfTeams == 2)
    }

    @Test func clampNumberOfTeamsKeepsValidValueUnchanged() {
        let viewModel = GroupDetailViewModel(modelContext: makeContext())
        viewModel.numberOfTeams = 3

        viewModel.clampNumberOfTeams(selectedCount: 10)

        #expect(viewModel.numberOfTeams == 3)
    }

    @Test func canGenerateTeamsRequiresAtLeastOnePlayerPerTeam() {
        let viewModel = GroupDetailViewModel(modelContext: makeContext())
        viewModel.numberOfTeams = 2

        #expect(viewModel.canGenerateTeams(selectedCount: 1) == false)
        #expect(viewModel.canGenerateTeams(selectedCount: 2) == true)
    }
}
