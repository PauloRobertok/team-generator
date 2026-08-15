//
//  GroupCardView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI

struct GroupCardView: View {
    let group: GroupGame
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(group.sport.color.opacity(0.15))
                        .frame(width: 54, height: 54)
                    Image(systemName: group.sport.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(group.sport.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("Sport: \(group.sport.label)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()

                if onEdit != nil || onDelete != nil {
                    Menu {
                        if let onEdit {
                            Button {
                                onEdit()
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                        }
                        if let onDelete {
                            Button(role: .destructive) {
                                onDelete()
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 10)

            HStack(spacing: 6) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .foregroundColor(Color.green)
                    .frame(width: 10, height: 10)
                Text("\(group.players.count) Players")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.leading, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.06), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    GroupCardView(group: GroupGame(
        name: "Tuesday Volleyball",
        sport: .volleyball,
        players: Array(repeating: Player(name: "Paulo", gender: .male, skillLevel: .pro), count: 16)
    ))
    GroupCardView(group: GroupGame(
        name: "Futsal Fridays",
        sport: .futsal,
        players: Array(repeating: Player(name: "Maria", gender: .female, skillLevel: .advanced), count: 10)
    ))
}
