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
    @State private var showingTableMode = false

    fileprivate static let blue = Color(red: 24.0 / 255, green: 95.0 / 255, blue: 165.0 / 255)
    fileprivate static let coral = Color(red: 216.0 / 255, green: 90.0 / 255, blue: 48.0 / 255)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView()
                normalContent
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
            // O modo mesa precisa ser um fullScreenCover, não uma troca de conteúdo dentro
            // da própria aba: essa tela vive dentro da tab bar, e a tab bar nunca some com
            // `.ignoresSafeArea()` — ela é desenhada pelo `TabView` pai, não por essa view.
            // Sem o cover, a área disponível pro GeometryReader fica menor que a tela cheia
            // e a matemática da rotação de 90° quebra. `LiveMatchView` não precisa disso
            // porque ELE já é inteiro apresentado como fullScreenCover pelo pai dele.
            .fullScreenCover(isPresented: $showingTableMode) {
                tableModeCover
            }
        }
    }

    // MARK: - Normal mode

    private var normalContent: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                ModeTogglePill(isTableMode: $showingTableMode)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            HStack(spacing: 0) {
                teamHalf(name: $nameA, score: $scoreA, color: Self.blue)
                teamHalf(name: $nameB, score: $scoreB, color: Self.coral)
            }

            resetButton
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

    // MARK: - Table mode

    private var tableModeCover: some View {
        ZStack(alignment: .top) {
            tableModeContent
            ModeTogglePill(isTableMode: $showingTableMode)
                .padding(.top, 12)
        }
    }

    /// Mesmo truque do `LiveMatchView`: conteúdo desenhado em dimensões de paisagem e
    /// girado 90° pra caber na tela em pé, sem travar a orientação do app inteiro.
    private var tableModeContent: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                tableHalf(name: $nameA, score: $scoreA, color: Self.blue)
                tableHalf(name: $nameB, score: $scoreB, color: Self.coral)
            }
            .frame(width: proxy.size.height, height: proxy.size.width)
            .rotationEffect(.degrees(90))
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }

    private func tableHalf(name: Binding<String>, score: Binding<Int>, color: Color) -> some View {
        VStack(spacing: 10) {
            TextField("Time", text: name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .padding(.horizontal, 8)

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
    ScoreboardView()
}
