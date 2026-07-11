//
//  GroupDetailViewState.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

enum GroupDetailViewState {
    case loading
    case loaded(groupGame: GroupGame)
    case error(message: String)
}
