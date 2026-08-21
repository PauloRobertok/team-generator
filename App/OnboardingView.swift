//
//  OnboardingView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 20/08/26.
//

import SwiftUI

private struct OnboardingPage {
    let icon: String
    let title: String
    let message: String
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "person.3.fill",
        title: "Bem-vindo ao TeamDraft",
        message: "Monte times equilibrados pros seus jogos em segundos, sem discussão no grupo do zap."
    ),
    OnboardingPage(
        icon: "folder.badge.plus",
        title: "Crie seu grupo",
        message: "Um grupo pra cada jogo fixo — vôlei de terça, futebol de quarta, o que for. Cadastre os jogadores uma vez só."
    ),
    OnboardingPage(
        icon: "wand.and.stars",
        title: "Gere times balanceados",
        message: "O app distribui por nível de habilidade automaticamente — ou sorteia, se preferir no aleatório."
    ),
    OnboardingPage(
        icon: "sportscourt.fill",
        title: "Acompanhe o jogo ao vivo",
        message: "Registre os confrontos, veja o histórico depois e quem tá invicto na quadra."
    ),
    OnboardingPage(
        icon: "square.split.2x1.fill",
        title: "Só precisa de um placar?",
        message: "Na aba Placar você conta pontos na hora, sem grupo nem cadastro — ideal pra um jogo avulso."
    )
]

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var pageIndex = 0

    private var isLastPage: Bool { pageIndex == onboardingPages.count - 1 }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $pageIndex) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.offset) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageDots

                actionButton
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
            }

            Button("Pular") {
                onFinish()
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.gray)
            .padding()
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            Spacer()

            RoundedRectangle(cornerRadius: 28)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 108, height: 108)
                .overlay(
                    Image(systemName: page.icon)
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                )

            Text(page.title)
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)

            Text(page.message)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            Spacer()
            Spacer()
        }
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(onboardingPages.indices, id: \.self) { index in
                Circle()
                    .fill(index == pageIndex ? Color.blue : Color.blue.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var actionButton: some View {
        Button {
            if isLastPage {
                onFinish()
            } else {
                withAnimation { pageIndex += 1 }
            }
        } label: {
            Text(isLastPage ? "Começar" : "Próximo")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
