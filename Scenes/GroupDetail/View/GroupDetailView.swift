//
//  GroupDetailView.swift
//  teamgenerator
//
//  Created by Ravi navarro on 06/06/26.
//

import SwiftUI

struct GroupDetailView: View {
    @StateObject private var viewModel: GroupDetailViewModel
    @State private var showingAddPlayer = false
    @State private var showingContacts = false
    @Environment(\.dismiss) var dismiss
    
    init(groupGame: GroupGame) {
        let repository = GroupDetailRepository()
        _viewModel = StateObject(wrappedValue: GroupDetailViewModel(groupGame: groupGame, repository: repository))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header sempre com dados do grupo (não precisa carregar)
                headerView
                
                // Conteúdo que muda com o estado
                switch viewModel.state {
                case .loading:
                    loadingView
                    
                case .loaded(let groupGame):
                    loadedView(groupGame: groupGame)
                    
                case .error(let message):
                    errorView(message: message)
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if case .loaded = viewModel.state {
                        FloatingActionButton(buttonSize: 60) {
                            FloatingAction(symbol: "person.2.fill", tint: .white, background: .blue.opacity(0.8)) {
                                showingContacts = true
                            }
                            
                            FloatingAction(symbol: "person.badge.plus.fill", tint: .white, background: .blue.opacity(0.8)) {
                                showingAddPlayer = true
                            }
                        } label: { isExpanded in
                            Image(systemName: "plus")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .rotationEffect(.init(degrees: isExpanded ? 45 : 0))
                                .scaleEffect(1.02)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.blue, in: .circle)
                                .scaleEffect(isExpanded ? 0.9 : 1)
                        }
                        .padding(.bottom, 66)
                        .padding(16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddPlayer) {
            Text("Add Player Sheet")
        }
        .sheet(isPresented: $showingContacts) {
            Text("Contacts Sheet")
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Header View (Always Visible - No Loading Needed)
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: viewModel.initialGroupGame.sport.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                
                Text(viewModel.initialGroupGame.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(viewModel.initialGroupGame.sport.color)
            .cornerRadius(8)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Loading State View
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Carregando grupo...")
                .tint(.blue)
            Spacer()
        }
    }
    
    // MARK: - Loaded State View
    
    private func loadedView(groupGame: GroupGame) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Jogadores")
                    .font(.system(size: 18, weight: .bold))
                
                Text("\(groupGame.players.count)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            if groupGame.players.isEmpty {
                emptyPlayersView
            } else {
                playersListView(groupGame: groupGame)
            }
            
            Spacer()
            
            // Generate Teams Button
            Button(action: {}) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Gerar Times")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    // MARK: - Empty Players View
    
    private var emptyPlayersView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Nenhum jogador adicionado")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Players List View
    
    private func playersListView(groupGame: GroupGame) -> some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(groupGame.players, id: \.id) { player in
                    PlayerDetailRowView(
                        player: player,
                        onEdit: {
                            // Edit action
                        },
                        onDelete: {
                            Task {
                                await viewModel.deletePlayer(player)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Error State View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Erro ao carregar grupo")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.gray)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await viewModel.loadData()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Tentar novamente")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
    }
}

#Preview {
    let samplePlayers = [
        Player(name: "Sarah", gender: .female, skillLevel: .advanced),
        Player(name: "Mike", gender: .male, skillLevel: .pro),
        Player(name: "Elena", gender: .female, skillLevel: .advanced),
        Player(name: "David", gender: .male, skillLevel: .intermediate),
        Player(name: "Alex", gender: .female, skillLevel: .beginner)
    ]
    
    let sampleGroup = GroupGame(name: "Tuesday Volleyball", sport: .volleyball, players: samplePlayers)
    
    GroupDetailView(groupGame: sampleGroup)
}
