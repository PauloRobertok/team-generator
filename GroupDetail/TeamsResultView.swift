//
//  TeamsResultView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI

struct TeamsResultView: View {
    let teams: [Team]
    let insufficientWomen: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if insufficientWomen {
                        Label("Não há mulheres suficientes para atingir o mínimo por time", systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundColor(.orange)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.12))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }

                    ForEach(teams) { team in
                        teamCard(team)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Times Gerados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    private func teamCard(_ team: Team) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(team.name)
                    .font(.headline)
                Spacer()
                Text(String(format: "Skill médio: %.1f", team.averageSkill))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            ForEach(team.players) { player in
                HStack {
                    Image(systemName: player.gender == .female ? "person.fill" : "person")
                        .foregroundColor(player.gender == .female ? .pink : .blue)
                    Text(player.name)
                    Spacer()
                    Text(player.skillLevel.label)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.06), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

#Preview {
    TeamsResultView(
        teams: [
            Team(name: "Time 1", players: [
                Player(name: "Mike", gender: .male, skillLevel: .pro),
                Player(name: "Sarah", gender: .female, skillLevel: .advanced)
            ]),
            Team(name: "Time 2", players: [
                Player(name: "David", gender: .male, skillLevel: .intermediate),
                Player(name: "Elena", gender: .female, skillLevel: .advanced)
            ])
        ],
        insufficientWomen: true
    )
}
