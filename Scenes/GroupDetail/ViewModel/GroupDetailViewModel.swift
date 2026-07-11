//
//  GroupDetailViewModel.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

import SwiftUI
import Combine

@MainActor
class GroupDetailViewModel: GroupDetailViewModelProtocol {
    @Published var state: GroupDetailViewState = .loading
    @Published var selectedPlayer: Player?
    
    private let repository: GroupDetailRepositoryProtocol
    var initialGroupGame: GroupGame
    let samplePlayers = [
        Player(name: "Sarah", gender: .female, skillLevel: .advanced),
        Player(name: "Mike", gender: .male, skillLevel: .pro),
        Player(name: "Elena", gender: .female, skillLevel: .advanced),
        Player(name: "David", gender: .male, skillLevel: .intermediate),
        Player(name: "Alex", gender: .female, skillLevel: .beginner)
    ]
    
    init(groupGame: GroupGame, repository: GroupDetailRepositoryProtocol) {
        self.initialGroupGame = groupGame
        self.repository = repository
        self.state = .loaded(groupGame: groupGame)
    }
    
    func loadData() async {
        state = .loading
        do {
            // Simular carregamento (em um caso real, você buscaria do repository)
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
            initialGroupGame = .init(name: "Turma do Bairro", sport: .basketball, players: samplePlayers)
            state = .loaded(groupGame: initialGroupGame)
        } catch {
            state = .error(message: "Erro ao carregar grupo: \(error.localizedDescription)")
        }
    }
    
    func deletePlayer(_ player: Player) async {
        do {
            try await repository.deletePlayer(player, from: initialGroupGame)
            
            if case .loaded(var groupGame) = state {
                if let index = groupGame.players.firstIndex(where: { $0.id == player.id }) {
                    groupGame.players.remove(at: index)
                    state = .loaded(groupGame: groupGame)
                }
            }
        } catch {
            state = .error(message: "Erro ao deletar jogador: \(error.localizedDescription)")
        }
    }
    
    func updatePlayer(_ player: Player) async {
        do {
            try await repository.updatePlayer(player, in: initialGroupGame)
            
            if case .loaded(var groupGame) = state {
                if let index = groupGame.players.firstIndex(where: { $0.id == player.id }) {
                    groupGame.players[index] = player
                    state = .loaded(groupGame: groupGame)
                }
            }
        } catch {
            state = .error(message: "Erro ao atualizar jogador: \(error.localizedDescription)")
        }
    }
    
    func addPlayer(_ player: Player) async {
        do {
            try await repository.addPlayer(player, to: initialGroupGame)
            
            if case .loaded(var groupGame) = state {
                groupGame.players.append(player)
                state = .loaded(groupGame: groupGame)
            }
        } catch {
            state = .error(message: "Erro ao adicionar jogador: \(error.localizedDescription)")
        }
    }
}
