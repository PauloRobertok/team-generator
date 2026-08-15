//
//  GroupsViewModel.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Foundation
import SwiftData

@MainActor
struct GroupsViewModel {
    let modelContext: ModelContext

    func addGroup(name: String, sport: SportType) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        modelContext.insert(GroupGame(name: trimmedName, sport: sport))
    }

    func deleteGroup(_ group: GroupGame) {
        modelContext.delete(group)
    }
}
