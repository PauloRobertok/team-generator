//
//  GroupDetailFactoryProtocol.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

import SwiftUI

protocol GroupDetailFactoryProtocol {
    associatedtype ViewType: View
    
    func makeRepository() -> GroupDetailRepositoryProtocol
    func makeViewModel(groupGame: GroupGame, repository: GroupDetailRepositoryProtocol) -> GroupDetailViewModel
    func makeView(groupGame: GroupGame) -> ViewType
}
