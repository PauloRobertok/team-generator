//
//  LiveMatchView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 18/08/26.
//

import SwiftUI
import SwiftData

struct LiveMatchView: View {
    let group: GroupGame
    let teams: [Team]

    @State private var engine: MatchQueueEngine
    @State private var scoreA = 0
    @State private var scoreB = 0
    @State private var matchNumber = 1
    @State private var showingScoreConfirm = false
    @State private var showingStopConfirm = false
    @State private var showingSummary = false
    @State private var resultBanner: String?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private static let blue = Color(red: 24.0 / 255, green: 95.0 / 255, blue: 165.0 / 255)
    private static let coral = Color(red: 216.0 / 255, green: 90.0 / 255, blue: 48.0 / 255)

    init(group: GroupGame, teams: [Team]) {
        self.group = group
        self.teams = teams
        _engine = State(initialValue: MatchQueueEngine(teams: teams, rule: group.matchRotationRule))
    }

    private var anyMatchPlayed: Bool {
        engine.stats.values.contains { $0.matchesPlayed > 0 }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        scoreboard
                        queuePreview

                        if let resultBanner {
                            Text(resultBanner)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 16)
                }

                confirmButton
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Confronto \(matchNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Parar") { showingStopConfirm = true }
                }
            }
            .confirmationDialog(
                "Confirmar placar \(scoreA)x\(scoreB)?",
                isPresented: $showingScoreConfirm,
                titleVisibility: .visible
            ) {
                Button("Confirmar") { confirmScore() }
                Button("Revisar", role: .cancel) {}
            } message: {
                Text(confirmMessage)
            }
            .confirmationDialog(
                "Encerrar confrontos?",
                isPresented: $showingStopConfirm,
                titleVisibility: .visible
            ) {
                Button("Encerrar", role: .destructive) { stopSession() }
                Button("Continuar jogando", role: .cancel) {}
            }
            .sheet(isPresented: $showingSummary) {
                SessionSummaryView(group: group, teams: teams, stats: engine.stats) {
                    dismiss()
                }
            }
        }
    }

    private func stopSession() {
        if anyMatchPlayed {
            showingSummary = true
        } else {
            let session = GameSession(name: group.name, sport: group.sport, status: .cancelled)
            modelContext.insert(session)
            dismiss()
        }
    }

    private var confirmMessage: String {
        let winnerName = scoreA > scoreB ? engine.court.teamA.name : engine.court.teamB.name
        return "\(winnerName) vence e avança pro próximo confronto."
    }

    // MARK: - Scoreboard

    private var scoreboard: some View {
        HStack(spacing: 0) {
            teamHalf(engine.court.teamA, score: $scoreA, color: Self.blue)
            teamHalf(engine.court.teamB, score: $scoreB, color: Self.coral)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func teamHalf(_ team: Team, score: Binding<Int>, color: Color) -> some View {
        VStack(spacing: 12) {
            Text(team.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            Text("\(score.wrappedValue)")
                .font(.system(size: 56, weight: .semibold))
                .foregroundColor(.white)
            HStack(spacing: 12) {
                scoreButton("minus") { score.wrappedValue = max(0, score.wrappedValue - 1) }
                scoreButton("plus") { score.wrappedValue += 1 }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(color)
    }

    private func scoreButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())
        }
    }

    // MARK: - Queue

    private var queuePreview: some View {
        Text("Fila: " + (engine.queue.isEmpty ? "ninguém esperando" : engine.queue.map(\.name).joined(separator: " · ")))
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Confirm

    private var confirmButton: some View {
        Button {
            guard scoreA != scoreB else { return }
            showingScoreConfirm = true
        } label: {
            Text("Confirmar Placar")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(scoreA == scoreB ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(scoreA == scoreB)
        .padding()
        .background(Color(.systemBackground))
    }

    private func confirmScore() {
        guard let outcome = try? engine.recordResult(scoreA: scoreA, scoreB: scoreB) else { return }
        resultBanner = outcome.winnerExited
            ? "\(outcome.winner.name) vence! 2 vitórias seguidas — sai com prioridade na fila."
            : "\(outcome.winner.name) vence e fica na quadra!"
        scoreA = 0
        scoreB = 0
        matchNumber += 1
    }
}

#Preview {
    let teams = [
        Team(name: "Time 1", players: [], badgeName: "Power Hitters"),
        Team(name: "Time 2", players: [], badgeName: "Rally Kings"),
        Team(name: "Time 3", players: [], badgeName: "Ace Squad"),
        Team(name: "Time 4", players: [], badgeName: "Block Party")
    ]
    LiveMatchView(
        group: GroupGame(name: "Vôlei de Terça", sport: .volleyball),
        teams: teams
    )
}
