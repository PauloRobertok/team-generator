//
//  HistoryView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 15/08/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameSession.date, order: .reverse) private var sessions: [GameSession]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView()

                if sessions.isEmpty {
                    emptyState
                } else {
                    List {
                        header
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                        ForEach(sessions) { session in
                            NavigationLink {
                                SessionDetailView(session: session)
                            } label: {
                                sessionCard(session)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Histórico")
                .font(.system(size: 28, weight: .bold))
            Text("Revise suas sessões e placares anteriores.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("Nenhuma sessão registrada ainda")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Suas sessões concluídas ou canceladas vão aparecer aqui")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Session card

    private func sessionCard(_ session: GameSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                HStack(spacing: 10) {
                    Image(systemName: session.sport.icon)
                        .font(.system(size: 16))
                        .foregroundColor(session.sport.color)
                        .frame(width: 32, height: 32)
                        .background(session.sport.color.opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.name)
                            .font(.system(size: 15, weight: .semibold))
                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                statusBadge(session.status)
            }

            if session.status == .completed && !session.teamResults.isEmpty {
                resultsList(session.teamResults)
            } else {
                Text("Nenhum placar registrado nessa sessão.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .contentShape(Rectangle())
    }

    private func statusBadge(_ status: SessionStatus) -> some View {
        Text(status.label.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(status == .completed ? .gray : .blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status == .completed ? Color.gray.opacity(0.15) : Color.blue.opacity(0.12))
            .clipShape(Capsule())
    }

    private func resultsList(_ results: [TeamResultSnapshot]) -> some View {
        let ranked = results.sorted { $0.matchesWon > $1.matchesWon || ($0.matchesWon == $1.matchesWon && $0.totalPoints > $1.totalPoints) }

        return VStack(spacing: 8) {
            ForEach(Array(ranked.enumerated()), id: \.offset) { index, result in
                HStack {
                    Text(result.name)
                        .font(.system(size: 13, weight: index == 0 ? .bold : .regular))
                    Text(result.badgeName)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(result.matchesWon) de \(result.matchesPlayed)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("\(result.totalPoints) pts")
                        .font(.system(size: 13, weight: index == 0 ? .bold : .regular))
                        .foregroundColor(index == 0 ? .primary : .gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HistoryView()
        .modelContainer(PreviewContainer.sample)
}
