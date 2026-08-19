//
//  PreviewContainer.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Foundation
import SwiftData

@MainActor
enum PreviewContainer {
    static let sample: ModelContainer = {
        let schema = Schema([GroupGame.self, Player.self, GameSession.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])

        let players = [
            Player(name: "Sarah", gender: .female, skillLevel: .advanced),
            Player(name: "Mike", gender: .male, skillLevel: .pro),
            Player(name: "Elena", gender: .female, skillLevel: .advanced),
            Player(name: "David", gender: .male, skillLevel: .intermediate),
            Player(name: "Alex", gender: .female, skillLevel: .beginner)
        ]
        let group = GroupGame(name: "Turma do Bairro", sport: .volleyball, players: players)
        container.mainContext.insert(group)

        let session = GameSession(
            name: "Vôlei de Terça",
            sport: .volleyball,
            date: Date(),
            status: .completed,
            teamResults: [
                TeamResultSnapshot(name: "Time 1", badgeName: "Power Hitters", matchesPlayed: 3, matchesWon: 2, totalPoints: 47),
                TeamResultSnapshot(name: "Time 2", badgeName: "Rally Kings", matchesPlayed: 2, matchesWon: 1, totalPoints: 31)
            ]
        )
        container.mainContext.insert(session)

        return container
    }()
}
