//
//  GroupDetailRepositoryProtocol.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

protocol GroupDetailRepositoryProtocol {
    func updatePlayer(_ player: Player, in groupGame: GroupGame) async throws
    func deletePlayer(_ player: Player, from groupGame: GroupGame) async throws
    func addPlayer(_ player: Player, to groupGame: GroupGame) async throws
}
