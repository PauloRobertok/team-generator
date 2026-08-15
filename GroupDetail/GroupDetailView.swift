//
//  GroupDetailView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI
import SwiftData

struct GroupDetailView: View {
    @Bindable var group: GroupGame

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: GroupDetailViewModel?
    @State private var showingAddPlayer = false
    @State private var showingGenerateSheet = false
    @State private var showingTeamsResult = false

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if group.players.isEmpty {
                emptyPlayersView
            } else {
                playersListView
            }

            Spacer()

            Button {
                showingGenerateSheet = true
            } label: {
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("Gerar Times")
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .disabled(group.players.isEmpty)
        }
        .overlay(alignment: .bottomTrailing) {
            FloatingActionButton(buttonSize: 60) {
                FloatingAction(symbol: "person.badge.plus.fill", tint: .white, background: .blue.opacity(0.8)) {
                    showingAddPlayer = true
                }
            } label: { isExpanded in
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .rotationEffect(.init(degrees: isExpanded ? 45 : 0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.blue, in: .circle)
            }
            .padding(.bottom, 76)
            .padding(.trailing, 16)
        }
        .navigationBarHidden(true)
        .onAppear {
            if viewModel == nil {
                viewModel = GroupDetailViewModel(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showingAddPlayer) {
            addPlayerSheet
        }
        .sheet(isPresented: $showingGenerateSheet) {
            generateTeamsSheet
        }
        .sheet(isPresented: $showingTeamsResult) {
            if let viewModel {
                TeamsResultView(teams: viewModel.generatedTeams, insufficientWomen: viewModel.insufficientWomen)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: group.sport.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                Text(group.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(group.sport.color)
            .cornerRadius(8)

            Spacer()

            Color.clear.frame(width: 16, height: 16)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var emptyPlayersView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            Text("Nenhum jogador adicionado")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var playersListView: some View {
        ScrollView {
            VStack(spacing: 8) {
                HStack {
                    Text("Jogadores")
                        .font(.system(size: 18, weight: .bold))
                    Text("\(group.players.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                ForEach(group.players) { player in
                    PlayerDetailRowView(
                        player: player,
                        onEdit: {},
                        onDelete: {
                            viewModel?.deletePlayer(player)
                        }
                    )
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Add Player Sheet

    @State private var newPlayerName = ""
    @State private var newPlayerGender: Gender = .male
    @State private var newPlayerSkill: SkillLevel = .beginner

    private var addPlayerSheet: some View {
        NavigationStack {
            Form {
                Section("Nome") {
                    TextField("Nome do jogador", text: $newPlayerName)
                }
                Section("Gênero") {
                    Picker("Gênero", selection: $newPlayerGender) {
                        Text("Masculino").tag(Gender.male)
                        Text("Feminino").tag(Gender.female)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Nível") {
                    Picker("Nível", selection: $newPlayerSkill) {
                        ForEach(SkillLevel.allCases, id: \.self) { skill in
                            Text(skill.label).tag(skill)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Novo Jogador")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        resetAddPlayerForm()
                        showingAddPlayer = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        viewModel?.addPlayer(name: newPlayerName, gender: newPlayerGender, skillLevel: newPlayerSkill, to: group)
                        resetAddPlayerForm()
                        showingAddPlayer = false
                    }
                    .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func resetAddPlayerForm() {
        newPlayerName = ""
        newPlayerGender = .male
        newPlayerSkill = .beginner
    }

    // MARK: - Generate Teams Sheet

    private var generateTeamsSheet: some View {
        NavigationStack {
            Form {
                Stepper(
                    "Número de times: \(viewModel?.numberOfTeams ?? 2)",
                    value: Binding(
                        get: { viewModel?.numberOfTeams ?? 2 },
                        set: { viewModel?.numberOfTeams = $0 }
                    ),
                    in: 2...max(2, group.players.count)
                )
                Text("Mínimo de mulheres por time: \(group.minWomenPerTeam)")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Gerar Times")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { showingGenerateSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gerar") {
                        viewModel?.generateTeams(for: group)
                        showingGenerateSheet = false
                        showingTeamsResult = true
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(group: GroupGame(
            name: "Turma do Bairro",
            sport: .basketball,
            players: [
                Player(name: "Sarah", gender: .female, skillLevel: .advanced),
                Player(name: "Mike", gender: .male, skillLevel: .pro),
                Player(name: "Elena", gender: .female, skillLevel: .advanced),
                Player(name: "David", gender: .male, skillLevel: .intermediate),
                Player(name: "Alex", gender: .female, skillLevel: .beginner)
            ]
        ))
    }
    .modelContainer(PreviewContainer.sample)
}
