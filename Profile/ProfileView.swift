//
//  ProfileView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 19/08/26.
//

import SwiftUI

/// Perfil local — sem conta nem backend ainda. Nome e cor do avatar ficam só no
/// dispositivo (`@AppStorage`). `AccountDetailsView` já deixa o lugar certo pra plugar
/// login de verdade (Google e afins) quando isso existir.
struct ProfileView: View {
    @AppStorage("profileName") private var profileName = "Seu Nome"
    @AppStorage("profileAvatarIndex") private var avatarIndex = 0

    @State private var showingEditProfile = false
    @State private var showingSignOutConfirm = false
    @State private var showingSignOutInfo = false

    static let avatarPalette: [Color] = [.blue, .purple, .teal, .orange, .pink, .green]

    private var avatarColor: Color {
        Self.avatarPalette[avatarIndex % Self.avatarPalette.count]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView()

                ScrollView {
                    VStack(spacing: 28) {
                        profileHeader
                        settingsSection
                        signOutButton
                    }
                    .padding(.vertical, 24)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileSheet(name: $profileName, avatarIndex: $avatarIndex)
            }
            .confirmationDialog(
                "Sair da conta?",
                isPresented: $showingSignOutConfirm,
                titleVisibility: .visible
            ) {
                Button("Sair", role: .destructive) { showingSignOutInfo = true }
                Button("Cancelar", role: .cancel) {}
            }
            .alert("Nenhuma conta vinculada", isPresented: $showingSignOutInfo) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Esse perfil ainda é só local. Quando o login por conta estiver disponível, isso vai desconectar sua conta de verdade.")
            }
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(avatarColor.opacity(0.18))
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundStyle(avatarColor)
                    )

                Button {
                    showingEditProfile = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(.systemGroupedBackground), lineWidth: 2))
                }
            }

            Text(profileName)
                .font(.system(size: 20, weight: .bold))
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Configurações")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                NavigationLink {
                    NotificationsSettingsView()
                } label: {
                    settingsRow(icon: "bell", title: "Notificações")
                }
                Divider().padding(.leading, 52)

                NavigationLink {
                    AccountDetailsView()
                } label: {
                    settingsRow(icon: "person.2.badge.gearshape", title: "Detalhes da Conta")
                }
                Divider().padding(.leading, 52)

                NavigationLink {
                    AppRulesView()
                } label: {
                    settingsRow(icon: "scalemass", title: "Regras e Conduta")
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
        }
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Sign out

    private var signOutButton: some View {
        Button {
            showingSignOutConfirm = true
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sair")
            }
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

private struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var avatarIndex: Int

    @Environment(\.dismiss) private var dismiss
    @State private var draftName: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Nome") {
                    TextField("Seu nome", text: $draftName)
                }
                Section("Cor do avatar") {
                    HStack(spacing: 14) {
                        ForEach(Array(ProfileView.avatarPalette.enumerated()), id: \.offset) { index, color in
                            Button {
                                avatarIndex = index
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: avatarIndex == index ? 2 : 0)
                                            .padding(-3)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { draftName = name }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
                        name = trimmed.isEmpty ? name : trimmed
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ProfileView()
}
