//
//  EditPlayerSheet.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 19/08/26.
//

import SwiftUI

/// Edita o jogador direto (mesmo padrão do GroupSettingsView — sem rascunho/cancelar,
/// as mudanças já valem na hora).
struct EditPlayerSheet: View {
    @Bindable var player: Player

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Nome") {
                    TextField("Nome do jogador", text: $player.name)
                }
                Section("Gênero") {
                    Picker("Gênero", selection: $player.gender) {
                        Text("Masculino").tag(Gender.male)
                        Text("Feminino").tag(Gender.female)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Nível") {
                    Picker("Nível", selection: $player.skillLevel) {
                        ForEach(SkillLevel.allCases, id: \.self) { skill in
                            Text(skill.label).tag(skill)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section("Posição") {
                    Picker("Posição", selection: $player.position) {
                        ForEach(PlayerPosition.options(for: player.group?.sport ?? .volleyball), id: \.self) { position in
                            Text(position.label).tag(position)
                        }
                    }
                }
            }
            .navigationTitle("Editar Jogador")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Pronto") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    EditPlayerSheet(player: Player(name: "Sarah", gender: .female, skillLevel: .advanced))
}
