//
//  TeamsResultView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI
import SwiftData

struct TeamsResultView: View {
    let group: GroupGame
    let viewModel: GroupDetailViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var showingLiveMatch = false

    private var teams: [Team] { viewModel.generatedTeams }

    private var shareText: String {
        var lines = ["\(group.name) — Times Gerados"]
        for team in teams {
            lines.append("\n\(team.name) (\(team.badgeName))")
            for player in team.players {
                lines.append("• \(player.name) — \(player.position.label)")
            }
        }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        banner

                        ForEach(teams) { team in
                            teamCard(team)
                        }
                    }
                    .padding(.vertical, 16)
                }

                footerButtons
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Times Gerados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showingLiveMatch) {
                LiveMatchView(group: group, teams: teams)
            }
        }
    }

    // MARK: - Banner

    private var banner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎉 Times Balanceados!")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Text("\(group.sport.label) • \(group.name)")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))

            modeBadge

            if group.minWomenPerTeam > 0 {
                ruleBadge
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack(alignment: .trailing) {
                LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: group.sport.icon)
                    .font(.system(size: 90))
                    .foregroundColor(.white.opacity(0.12))
                    .padding(.trailing, -10)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var modeBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: viewModel.generationMode == .balanced ? "scalemass.fill" : "shuffle")
                .font(.system(size: 12))
            Text("Modo: \(viewModel.generationMode.label)")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.2))
        .clipShape(Capsule())
    }

    private var ruleBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: viewModel.insufficientWomen ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .font(.system(size: 12))
            Text(
                viewModel.insufficientWomen
                    ? "Mulheres insuficientes pra atingir o mínimo por time"
                    : "Regra atendida: mín. \(group.minWomenPerTeam) mulher(es) por time"
            )
            .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.2))
        .clipShape(Capsule())
    }

    // MARK: - Team card

    private func teamCard(_ team: Team) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.blue)
                    Text(String(format: "Skill médio: %.1f", team.averageSkill))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(team.badgeName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Capsule())
            }

            Divider()

            VStack(spacing: 10) {
                ForEach(team.players) { player in
                    playerRow(player, isCaptain: player.id == team.captain?.id)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }

    private func playerRow(_ player: Player, isCaptain: Bool) -> some View {
        HStack(spacing: 12) {
            PlayerAvatarView(player: player, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 15, weight: .semibold))
                Text("\(player.position.label) • Skill \(player.skillLevel.rawValue)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            if isCaptain {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
        }
    }

    // MARK: - Footer

    private var footerButtons: some View {
        VStack(spacing: 10) {
            Button {
                showingLiveMatch = true
            } label: {
                HStack {
                    Image(systemName: "sportscourt.fill")
                    Text("Iniciar Confrontos")
                }
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            HStack(spacing: 12) {
                ShareLink(item: shareText) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Compartilhar")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }

                Button {
                    viewModel.generateTeams(for: group)
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Sortear")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    let group = GroupGame(
        name: "Wednesday Night League",
        sport: .volleyball,
        minWomenPerTeam: 1,
        players: [
            Player(name: "Alex M.", gender: .male, skillLevel: .expert, position: .setter),
            Player(name: "Sarah L.", gender: .female, skillLevel: .pro, position: .libero),
            Player(name: "Mike S.", gender: .male, skillLevel: .pro, position: .spiker)
        ]
    )
    let viewModel = GroupDetailViewModel(modelContext: PreviewContainer.sample.mainContext)
    viewModel.numberOfTeams = 2
    viewModel.generateTeams(for: group)

    return TeamsResultView(group: group, viewModel: viewModel)
}
