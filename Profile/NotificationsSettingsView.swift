//
//  NotificationsSettingsView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 19/08/26.
//

import SwiftUI

/// Preferências salvas localmente — não há envio de notificação push de verdade ainda,
/// já que o app não tem backend. Guarda a preferência pra quando isso existir.
struct NotificationsSettingsView: View {
    @AppStorage("notif.sessionReminders") private var sessionReminders = true
    @AppStorage("notif.groupUpdates") private var groupUpdates = true
    @AppStorage("notif.appNews") private var appNews = false

    var body: some View {
        Form {
            Section {
                Toggle("Lembretes de sessão", isOn: $sessionReminders)
                Toggle("Atualizações dos grupos", isOn: $groupUpdates)
                Toggle("Novidades do app", isOn: $appNews)
            } footer: {
                Text("Essas preferências ficam salvas no aparelho. O envio de notificações push ainda não está disponível nessa versão.")
            }
        }
        .navigationTitle("Notificações")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
}
