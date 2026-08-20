//
//  SessionDetailView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 19/08/26.
//

import SwiftUI

struct SessionDetailView: View {
    let session: GameSession

    private var rankedResults: [TeamResultSnapshot] {
        session.teamResults.sorted { lhs, rhs in
            if lhs.matchesWon != rhs.matchesWon { return lhs.matchesWon > rhs.matchesWon }
            return lhs.totalPoints > rhs.totalPoints
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerInfo

                if !rankedResults.isEmpty {
                    standingsSection
                }

                if !session.matchLog.isEmpty {
                    matchLogSection
                } else if session.status == .completed {
                    Text("Essa sessão foi salva antes do histórico detalhado de confrontos existir — só o total final ficou registrado.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerInfo: some View {
        HStack {
            Image(systemName: session.sport.icon)
                .foregroundColor(session.sport.color)
            Text(session.date.formatted(date: .long, time: .shortened))
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Spacer()
            statusBadge
        }
        .padding(.horizontal)
    }

    private var statusBadge: some View {
        Text(session.status.label.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(session.status == .completed ? .gray : .blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(session.status == .completed ? Color.gray.opacity(0.15) : Color.blue.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Standings

    private var standingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Classificação final")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(rankedResults.enumerated()), id: \.offset) { index, result in
                    if index > 0 {
                        Divider()
                    }
                    standingsRow(index: index, result: result)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
        }
    }

    private func standingsRow(index: Int, result: TeamResultSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(width: 18)
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .font(.system(size: 14, weight: index == 0 ? .bold : .regular))
                    Text(result.badgeName)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("\(result.matchesWon) de \(result.matchesPlayed)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text("\(result.totalPoints) pts")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 64, alignment: .trailing)
            }

            if !result.playerNames.isEmpty {
                Text(result.playerNames.joined(separator: ", "))
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .padding(.leading, 26)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Match log

    private var matchLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Confrontos")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(Array(session.matchLog.enumerated()), id: \.offset) { index, match in
                    matchRow(index: index, match: match)
                }
            }
            .padding(.horizontal)
        }
    }

    private func matchRow(index: Int, match: MatchQueueEngine.MatchRecord) -> some View {
        HStack(spacing: 8) {
            Text("#\(index + 1)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 22, alignment: .leading)

            Text(match.teamAName)
                .font(.system(size: 13, weight: match.winnerName == match.teamAName ? .bold : .regular))
                .lineLimit(1)

            scoreBadge(match.scoreA, isWinner: match.winnerName == match.teamAName)

            Text("x")
                .font(.system(size: 11))
                .foregroundColor(.gray.opacity(0.6))

            scoreBadge(match.scoreB, isWinner: match.winnerName == match.teamBName)

            Text(match.teamBName)
                .font(.system(size: 13, weight: match.winnerName == match.teamBName ? .bold : .regular))
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func scoreBadge(_ score: Int, isWinner: Bool) -> some View {
        Text("\(score)")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(isWinner ? .blue : .primary)
            .frame(minWidth: 22)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(isWinner ? Color.blue.opacity(0.12) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: GameSession(
            name: "Vôlei de Terça",
            sport: .volleyball,
            status: .completed,
            teamResults: [
                TeamResultSnapshot(name: "Time 1", badgeName: "Power Hitters", matchesPlayed: 3, matchesWon: 2, totalPoints: 47, playerNames: ["Alex M.", "Sarah L.", "Jordan P."]),
                TeamResultSnapshot(name: "Time 2", badgeName: "Rally Kings", matchesPlayed: 2, matchesWon: 1, totalPoints: 31, playerNames: ["Mike S.", "Elena C.", "Tom W."])
            ],
            matchLog: [
                MatchQueueEngine.MatchRecord(teamAName: "Time 1", teamBName: "Time 2", scoreA: 21, scoreB: 15, winnerName: "Time 1"),
                MatchQueueEngine.MatchRecord(teamAName: "Time 1", teamBName: "Time 2", scoreA: 18, scoreB: 21, winnerName: "Time 2")
            ]
        ))
    }
}
