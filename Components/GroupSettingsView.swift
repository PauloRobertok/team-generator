//
//  GroupSettingsView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 15/08/26.
//

import SwiftUI

struct GroupSettingsView: View {
    @Bindable var group: GroupGame
    var onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Nome do Grupo") {
                    TextField("Nome do grupo", text: $group.name)
                }

                Section("Tipo de Esporte") {
                    Picker("Esporte", selection: $group.sport) {
                        ForEach(SportType.allCases, id: \.self) { sport in
                            HStack {
                                Image(systemName: sport.icon)
                                Text(sport.label)
                            }
                            .tag(sport)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    Stepper(
                        "Mínimo de mulheres por time: \(group.minWomenPerTeam)",
                        value: $group.minWomenPerTeam,
                        in: 0...10
                    )
                } header: {
                    Text("Regra do Sorteio")
                } footer: {
                    Text("0 = sem regra, o sorteio equilibra só por habilidade, ignorando gênero.")
                }

                Section {
                    Picker("Regra de confronto", selection: $group.matchRotationRule) {
                        ForEach(MatchRotationRule.allCases, id: \.self) { rule in
                            Text(rule.label).tag(rule)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Confronto ao Vivo")
                } footer: {
                    Text(group.matchRotationRule.explanation)
                }

                Section {
                    Button("Excluir Grupo", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Pronto") { dismiss() }
                }
            }
            .confirmationDialog(
                "Excluir \"\(group.name)\"?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Excluir Grupo", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Isso vai excluir também os \(group.players.count) jogadores cadastrados nesse grupo. Essa ação não pode ser desfeita.")
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    GroupSettingsView(
        group: GroupGame(name: "Vôlei de Terça", sport: .volleyball),
        onDelete: {}
    )
}
