//
//  PlayerAvatarView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 15/08/26.
//

import SwiftUI

/// Avatar genérico por gênero, escolhido de um pool fixo de 4 cores por
/// `player.avatarIndex` (definido uma vez na criação do jogador). Placeholder
/// até termos ilustrações reais.
struct PlayerAvatarView: View {
    let player: Player
    var size: CGFloat = 48

    private static let malePalette: [Color] = [.blue, .teal, .indigo, .cyan]
    private static let femalePalette: [Color] = [.pink, .purple, .orange, .red]

    private var backgroundColor: Color {
        let palette = player.gender == .female ? Self.femalePalette : Self.malePalette
        return palette[player.avatarIndex % palette.count]
    }

    var body: some View {
        Circle()
            .fill(backgroundColor.opacity(0.18))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(backgroundColor)
            )
    }
}

#Preview {
    HStack {
        PlayerAvatarView(player: Player(name: "A", gender: .male, skillLevel: .beginner))
        PlayerAvatarView(player: Player(name: "B", gender: .female, skillLevel: .beginner))
    }
}
