//
//  AppRulesView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 19/08/26.
//

import SwiftUI

struct AppRulesView: View {
    private let sections: [(title: String, body: String)] = [
        (
            "Sorteio de times",
            "Times gerados no modo Equilibrado levam em conta o nível de cada jogador pra deixar os confrontos parelhos. No modo Aleatório, a divisão é só por sorte — nenhum dos dois modos considera nada além do que está configurado no grupo."
        ),
        (
            "Mínimo de mulheres por time",
            "Quando ativada, essa regra reserva um número mínimo de jogadoras por time antes de distribuir o restante. Se não houver jogadoras suficientes confirmadas, o app avisa antes de gerar os times."
        ),
        (
            "Regra de confronto",
            "Na sequenciada, quem vence fica na quadra. Na \"2 vitórias e sai\", um time que vence dois confrontos seguidos dá lugar aos times de fora antes de voltar a jogar — pensada pra sessões com bastante gente esperando a vez."
        ),
        (
            "Conduta esperada",
            "Registrar o placar com honestidade é o que faz o histórico da sessão valer alguma coisa. Times e sessões podem ser corrigidos ou refeitos a qualquer momento pelo organizador do grupo."
        )
    ]

    var body: some View {
        List {
            ForEach(sections, id: \.title) { section in
                Section(section.title) {
                    Text(section.body)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Regras e Conduta")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppRulesView()
    }
}
