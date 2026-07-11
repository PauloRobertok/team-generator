//
//  GroupDetailRepository.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

import Foundation
import CoreData

class GroupDetailRepository: GroupDetailRepositoryProtocol {
    private let persistence = PersistenceController.shared
    
    func updatePlayer(_ player: Player, in groupGame: GroupGame) async throws {
        let context = persistence.container.newBackgroundContext()
        try await context.perform {
            // Implementação de atualização do player
        }
    }
    
    func deletePlayer(_ player: Player, from groupGame: GroupGame) async throws {
        let context = persistence.container.newBackgroundContext()
        try await context.perform {
            // Implementação de deleção do player
        }
    }
    
    func addPlayer(_ player: Player, to groupGame: GroupGame) async throws {
        let context = persistence.container.newBackgroundContext()
        try await context.perform {
            // Implementação de adição do player
        }
    }
}
