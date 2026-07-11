//
//  GroupDetailFactory.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

import SwiftUI

class GroupDetailFactory: GroupDetailFactoryProtocol {
    typealias ViewType = GroupDetailView
    
    func makeRepository() -> GroupDetailRepositoryProtocol {
        GroupDetailRepository()
    }
    
    func makeViewModel(groupGame: GroupGame, repository: GroupDetailRepositoryProtocol) -> GroupDetailViewModel {
        GroupDetailViewModel(
            groupGame: groupGame,
            repository: repository
        )
    }
    
    func makeView(groupGame: GroupGame) -> GroupDetailView {
        GroupDetailView(groupGame: groupGame)
    }
}
