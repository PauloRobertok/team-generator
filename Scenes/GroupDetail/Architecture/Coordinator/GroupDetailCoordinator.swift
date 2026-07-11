//
//  GroupDetailCoordinator.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

import SwiftUI

class GroupDetailCoordinator {
    private let factory: any GroupDetailFactoryProtocol
    
    init(factory: any GroupDetailFactoryProtocol = GroupDetailFactory()) {
        self.factory = factory
    }
    
    func show(groupGame: GroupGame) -> AnyView {
        AnyView(factory.makeView(groupGame: groupGame))
    }
}
