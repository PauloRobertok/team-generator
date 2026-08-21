//
//  ScoreboardView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 20/08/26.
//

import SwiftUI

/// Placar avulso — sem grupo, sem jogadores, sem histórico. Porta de entrada mais simples
/// do app: pra quem só quer contar ponto de um jogo qualquer, sem se comprometer com o
/// fluxo completo de grupos/times. Reaproveita o visual do placar do modo mesa
/// (`LiveMatchView`), mas de propósito não reaproveita o código dele — ali é amarrado a
/// grupo/times gerados/regra de rotação, e essa tela precisa funcionar sem nenhum dos três.
struct ScoreboardView: View {
    @State private var nameA = "Time A"
    @State private var nameB = "Time B"
    @State private var scoreA = 0
    @State private var scoreB = 0
    @State private var showingResetConfirm = false

    fileprivate static let blue = Color(red: 24.0 / 255, green: 95.0 / 255, blue: 165.0 / 255)
    fileprivate static let coral = Color(red: 216.0 / 255, green: 90.0 / 255, blue: 48.0 / 255)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView()

                HStack(spacing: 0) {
                    teamHalf(name: $nameA, score: $scoreA, color: Self.blue)
                    teamHalf(name: $nameB, score: $scoreB, color: Self.coral)
                }

                resetButton
            }
            .navigationBarHidden(true)
            .confirmationDialog(
                "Reiniciar placar?",
                isPresented: $showingResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reiniciar", role: .destructive) {
                    scoreA = 0
                    scoreB = 0
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }

    private func teamHalf(name: Binding<String>, score: Binding<Int>, color: Color) -> some View {
        VStack(spacing: 16) {
            TextField("Nome do time", text: name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)

            Text("\(score.wrappedValue)")
                .font(.system(size: 88, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.4)

            HStack(spacing: 20) {
                scoreButton("minus") { score.wrappedValue = max(0, score.wrappedValue - 1) }
                scoreButton("plus") { score.wrappedValue += 1 }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
    }

    private func scoreButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())
        }
    }

    private var resetButton: some View {
        Button {
            showingResetConfirm = true
        } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Reiniciar Placar")
            }
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    ScoreboardView()
}
