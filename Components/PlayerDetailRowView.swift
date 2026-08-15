//
//  PlayerDetailRowView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI

struct PlayerDetailRowView: View {
    let player: Player
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var isSelectedBinding: Binding<Bool> {
        Binding(
            get: { player.isSelected },
            set: { player.isSelected = $0 }
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            PlayerAvatarView(player: player)

            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.system(size: 16, weight: .semibold))

                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(index < player.skillLevel.rawValue ? .yellow : .gray.opacity(0.3))
                    }
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                }

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                }

                Toggle("", isOn: isSelectedBinding)
                    .labelsHidden()
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    PlayerDetailRowView(
        player: Player(name: "Sarah", gender: .female, skillLevel: .advanced),
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
