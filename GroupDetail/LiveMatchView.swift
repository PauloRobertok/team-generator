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
    @State private var showingTableMode = false
    @State private var showingTieWarning = false
    @State private var resultBanner: String?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    fileprivate static let blue = Color(red: 24.0 / 255, green: 95.0 / 255, blue: 165.0 / 255)
    fileprivate static let coral = Color(red: 216.0 / 255, green: 90.0 / 255, blue: 48.0 / 255)

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
            // O pill fica num único lugar, desenhado pelo pai por cima dos dois modos — não
            // é duplicado em cada tela, então a posição nunca muda ao trocar de modo (como
            // uma tab bar: o controle fica fixo, só o que está selecionado muda).
            ZStack(alignment: .top) {
                if showingTableMode {
                    tableModeContent
                } else {
                    normalContent
                }

                ModeTogglePill(isTableMode: $showingTableMode)
                    .padding(.top, 12)
            }
            .toolbar(.hidden, for: .navigationBar)
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
                SessionSummaryView(group: group, teams: teams, stats: engine.stats, matchLog: engine.matchLog) {
                    dismiss()
                }
            }
            .alert("Empate não decide o confronto", isPresented: $showingTieWarning) {
                Button("Entendi", role: .cancel) {}
            } message: {
                Text("Ajusta o placar — precisa haver um vencedor pra avançar pro próximo confronto.")
            }
        }
    }

    // MARK: - Normal content

    private var normalContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 44)

                    HStack {
                        Text("Confronto \(matchNumber)")
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                        Button("Parar") { showingStopConfirm = true }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)

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

                    if anyMatchPlayed {
                        standingsCard
                    }
                }
                .padding(.vertical, 16)
            }

            confirmButton
        }
        .background(Color(.systemGroupedBackground))
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

    // MARK: - Standings

    /// Classificação ao vivo — pra galera acompanhar quem tá ganhando enquanto a sessão
    /// continua, em vez de só descobrir no resumo final. Só aparece depois do primeiro
    /// confronto (antes disso, todo mundo tá empatado em 0, não ajuda em nada mostrar).
    private var standingsCard: some View {
        let ranked = teams
            .map { ($0, engine.stats[$0.id] ?? MatchQueueEngine.TeamStats()) }
            .sorted { lhs, rhs in
                if lhs.1.matchesWon != rhs.1.matchesWon { return lhs.1.matchesWon > rhs.1.matchesWon }
                return lhs.1.totalPoints > rhs.1.totalPoints
            }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Classificação")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(ranked.enumerated()), id: \.element.0.id) { index, entry in
                    if index > 0 {
                        Divider()
                    }
                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 18)
                        Text(entry.0.name)
                            .font(.system(size: 14, weight: index == 0 ? .bold : .regular))
                        Spacer()
                        Text("\(entry.1.matchesWon) vit.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text("\(entry.1.totalPoints) pts")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(width: 64, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
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
            if scoreA == scoreB {
                showingTieWarning = true
            } else {
                showingScoreConfirm = true
            }
        } label: {
            Text("Confirmar Placar")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(scoreA == scoreB ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
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

    // MARK: - Table mode content

    /// Conteúdo desenhado em dimensões de paisagem (largura/altura trocadas via
    /// GeometryReader) e girado 90° pra caber na tela em pé — assim quem segura o celular
    /// vira ele de lado pros times, sem precisar travar a orientação do app inteiro em
    /// paisagem. Pensado pra grupos sem placar físico: alguém fica com o celular virado
    /// pros dois times, número bem grande, visível de longe. O pill de troca de modo NÃO
    /// mora aqui — é o mesmo componente desenhado pelo pai por cima dos dois modos.
    private var tableModeContent: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                tableHalf(team: engine.court.teamA, score: $scoreA, color: Self.blue)
                tableHalf(team: engine.court.teamB, score: $scoreB, color: Self.coral)
            }
            .frame(width: proxy.size.height, height: proxy.size.width)
            .rotationEffect(.degrees(90))
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }

    private func tableHalf(team: Team, score: Binding<Int>, color: Color) -> some View {
        VStack(spacing: 10) {
            Text(team.name.uppercased())
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            Text("\(score.wrappedValue)")
                .font(.system(size: 108, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            HStack(spacing: 36) {
                miniScoreButton("minus") { score.wrappedValue = max(0, score.wrappedValue - 1) }
                miniScoreButton("plus") { score.wrappedValue += 1 }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
    }

    private func miniScoreButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())
        }
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

/// Alterna entre a tela normal e o modo mesa. O lado ativo sempre aparece marcado em
/// branco.
private struct ModeTogglePill: View {
    @Binding var isTableMode: Bool

    var body: some View {
        HStack(spacing: 2) {
            segment(label: "Normal", systemImage: "rectangle.portrait", isActive: !isTableMode) {
                isTableMode = false
            }
            segment(label: "Mesa", systemImage: "rectangle.landscape.rotate", isActive: isTableMode) {
                isTableMode = true
            }
        }
        .padding(3)
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
    }

    private func segment(label: String, systemImage: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(label)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(isActive ? .black : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isActive ? Color.white : Color.clear)
            .clipShape(Capsule())
        }
        .disabled(isActive)
    }
}
