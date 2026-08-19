//
//  AccountDetailsView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 19/08/26.
//

import SwiftUI

/// "Contas Vinculadas" é só o lugar reservado pra quando existir login de verdade
/// (Google e outros provedores, várias contas linkadas). Por enquanto tudo aqui é local
/// — sem servidor, sem sessão, sem sincronização entre aparelhos.
struct AccountDetailsView: View {
    @AppStorage("profileName") private var profileName = "Seu Nome"

    var body: some View {
        Form {
            Section("Perfil local") {
                LabeledContent("Nome", value: profileName)
                LabeledContent("Tipo de conta", value: "Local (sem login)")
            }

            Section {
                linkedAccountRow(icon: "g.circle.fill", name: "Google", color: .red)
                linkedAccountRow(icon: "apple.logo", name: "Apple", color: .primary)
            } header: {
                Text("Contas vinculadas")
            } footer: {
                Text("Em breve: entre com Google, Apple ou outra conta pra sincronizar seus grupos entre aparelhos e vincular várias contas ao mesmo perfil.")
            }
        }
        .navigationTitle("Detalhes da Conta")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func linkedAccountRow(icon: String, name: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 28)
            Text(name)
                .foregroundColor(.primary)
            Spacer()
            Text("Em breve")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.15))
                .clipShape(Capsule())
        }
        .opacity(0.6)
    }
}

#Preview {
    NavigationStack {
        AccountDetailsView()
    }
}
