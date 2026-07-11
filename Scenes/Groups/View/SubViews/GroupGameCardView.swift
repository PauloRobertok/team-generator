//
//  GroupGameCardView.swift
//  teamgenerator
//
//  Created by Paulo Roberto on 28/05/26.
//

import SwiftUI

struct GroupGameCardView: View {
    let group: GroupGame
    private let detailCoordinator = GroupDetailCoordinator()
    
    var body: some View {
        NavigationLink(destination: detailCoordinator.show(groupGame: group)) {
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
                            .foregroundColor(.black)
                        Text("Sport: \(group.sport.label)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 10)

                HStack(spacing: 6) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .foregroundColor(Color.green)
                        .frame(width: 10, height: 10)
                    Text("\(group.players.count) Players")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.leading, 4)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.06), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    GroupGameCardView(group: GroupGame(
        name: "Tuesday Volleyball",
        sport: .volleyball,
        players: Array(repeating: Player(name: "Paulo", gender: .male, skillLevel: .pro), count: 16)
    ))
    GroupGameCardView(group: GroupGame(
        name: "Futsal Fridays",
        sport: .futsal,
        players: Array(repeating: Player(name: "Maria", gender: .female, skillLevel: .advanced), count: 10)
    ))
    GroupGameCardView(group: GroupGame(
        name: "Morning Hoops",
        sport: .basketball,
        players: Array(repeating: Player(name: "João", gender: .male, skillLevel: .intermediate), count: 12)
    ))
}
