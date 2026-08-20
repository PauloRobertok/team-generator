//
//  AppearanceSettingsView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 20/08/26.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"

    var label: String {
        switch self {
        case .light: return "Claro"
        case .dark: return "Escuro"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// O app ignora o modo do sistema de propósito — o layout não foi desenhado pro escuro
/// ainda, então força claro por padrão e só troca se a pessoa escolher aqui.
struct AppearanceSettingsView: View {
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.light.rawValue

    private var appearanceMode: Binding<AppearanceMode> {
        Binding(
            get: { AppearanceMode(rawValue: appearanceModeRaw) ?? .light },
            set: { appearanceModeRaw = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            Section {
                Picker("Aparência", selection: appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text("Define o tema do app, independente do modo claro/escuro configurado no seu iPhone.")
            }
        }
        .navigationTitle("Aparência")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
