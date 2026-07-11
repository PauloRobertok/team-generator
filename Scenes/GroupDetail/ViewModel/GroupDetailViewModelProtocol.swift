//
//  GroupDetailViewModelProtocol.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

import SwiftUI

protocol GroupDetailViewModelProtocol: ObservableObject {
    var state: GroupDetailViewState { get set }
    var selectedPlayer: Player? { get set }
    func deletePlayer(_ player: Player) async
    func updatePlayer(_ player: Player) async
    func addPlayer(_ player: Player) async
    func loadData() async
}
