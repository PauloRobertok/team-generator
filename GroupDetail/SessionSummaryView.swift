//
//  SessionSummaryView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 18/08/26.
//

import SwiftUI
import SwiftData

struct SessionSummaryView: View {
    let group: GroupGame
    let teams: [Team]
    let stats: [UUID: MatchQueueEngine.TeamStats]
    let matchLog: [MatchQueueEngine.MatchRecord]
    var onFinish: () -> Void

    @Environment(\.modelContext) private var modelContext

    private var rankedResults: [(team: Team, stats: MatchQueueEngine.TeamStats)] {
        teams
            .map { ($0, stats[$0.id] ?? MatchQueueEngine.TeamStats()) }
            .sorted { lhs, rhs in
                if lhs.1.matchesWon != rhs.1.matchesWon { return lhs.1.matchesWon > rhs.1.matchesWon }
                return lhs.1.totalPoints > rhs.1.totalPoints
            }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sessão encerrada")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 8)

                        resultsCard
                    }
                    .padding(.vertical, 8)
                }

                saveButton
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var resultsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Time").font(.system(size: 12, weight: .medium)).foregroundColor(.gray)
                Spacer()
                Text("Confrontos").font(.system(size: 12, weight: .medium)).foregroundColor(.gray)
                Text("Pontos").font(.system(size: 12, weight: .medium)).foregroundColor(.gray).frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            ForEach(rankedResults, id: \.team.id) { entry in
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.team.name)
                            .font(.system(size: 14, weight: .semibold))
                        Text(entry.team.badgeName)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("\(entry.stats.matchesWon) de \(entry.stats.matchesPlayed)")
                        .font(.system(size: 13))
                    Text("\(entry.stats.totalPoints)")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 60, alignment: .trailing)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }

    private var saveButton: some View {
        Button {
            saveSession()
            onFinish()
        } label: {
            Text("Salvar no Histórico")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private func saveSession() {
        let results = teams.map { team in
            TeamResultSnapshot(
                name: team.name,
                badgeName: team.badgeName,
                matchesPlayed: stats[team.id]?.matchesPlayed ?? 0,
                matchesWon: stats[team.id]?.matchesWon ?? 0,
                totalPoints: stats[team.id]?.totalPoints ?? 0,
                playerNames: team.players.map(\.name)
            )
        }
        let session = GameSession(
            name: group.name,
            sport: group.sport,
            status: .completed,
            teamResults: results,
            matchLog: matchLog
        )
        modelContext.insert(session)
    }
}

#Preview {
    let teams = [
        Team(name: "Time 1", players: [], badgeName: "Power Hitters"),
        Team(name: "Time 2", players: [], badgeName: "Rally Kings")
    ]
    SessionSummaryView(
        group: GroupGame(name: "Vôlei de Terça", sport: .volleyball),
        teams: teams,
        stats: [
            teams[0].id: MatchQueueEngine.TeamStats(matchesPlayed: 3, matchesWon: 2, totalPoints: 47),
            teams[1].id: MatchQueueEngine.TeamStats(matchesPlayed: 2, matchesWon: 1, totalPoints: 31)
        ],
        matchLog: [],
        onFinish: {}
    )
    .modelContainer(PreviewContainer.sample)
}
