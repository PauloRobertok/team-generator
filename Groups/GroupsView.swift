//
//  GroupsView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI
import SwiftData

struct GroupsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GroupGame.createdAt, order: .reverse) private var groups: [GroupGame]

    @State private var showingCreateSheet = false
    @State private var newGroupName = ""
    @State private var selectedSport: SportType = .volleyball
    @State private var editingGroup: GroupGame?
    @State private var groupPendingDeletion: GroupGame?

    private var viewModel: GroupsViewModel { GroupsViewModel(modelContext: modelContext) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("Seus Times")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 16)

                        if groups.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(groups) { group in
                                NavigationLink(value: group) {
                                    GroupCardView(
                                        group: group,
                                        onEdit: { editingGroup = group },
                                        onDelete: { groupPendingDeletion = group }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                        }

                        createGroupButton
                    }
                }
            }
            .navigationDestination(for: GroupGame.self) { group in
                GroupDetailView(group: group)
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            createGroupSheet
        }
        .sheet(item: $editingGroup) { group in
            GroupSettingsView(group: group) {
                viewModel.deleteGroup(group)
                editingGroup = nil
            }
        }
        .confirmationDialog(
            "Excluir \"\(groupPendingDeletion?.name ?? "")\"?",
            isPresented: Binding(
                get: { groupPendingDeletion != nil },
                set: { if !$0 { groupPendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Excluir Grupo", role: .destructive) {
                if let group = groupPendingDeletion {
                    viewModel.deleteGroup(group)
                }
                groupPendingDeletion = nil
            }
        } message: {
            if let group = groupPendingDeletion {
                Text("Isso vai excluir também os \(group.players.count) jogadores cadastrados nesse grupo. Essa ação não pode ser desfeita.")
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("Nenhum grupo criado")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Comece criando um grupo")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var createGroupButton: some View {
        Button {
            showingCreateSheet = true
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.title3)
                Text("Criar Novo Grupo")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .foregroundColor(.blue)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }

    private var createGroupSheet: some View {
        NavigationStack {
            Form {
                Section("Nome do Grupo") {
                    TextField("Ex: Vôlei da Praia", text: $newGroupName)
                }

                Section("Tipo de Esporte") {
                    Picker("Esporte", selection: $selectedSport) {
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
            }
            .navigationTitle("Novo Grupo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        resetForm()
                        showingCreateSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        viewModel.addGroup(name: newGroupName, sport: selectedSport)
                        resetForm()
                        showingCreateSheet = false
                    }
                    .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func resetForm() {
        newGroupName = ""
        selectedSport = .volleyball
    }
}

#Preview {
    GroupsView()
        .modelContainer(PreviewContainer.sample)
}
