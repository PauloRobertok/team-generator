//
//  ModeTogglePill.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 20/08/26.
//

import SwiftUI

/// Alterna entre a tela normal e o modo mesa. O lado ativo sempre aparece marcado em
/// branco. Compartilhado entre `LiveMatchView` e `ScoreboardView` — mesmo controle visual
/// pros dois lugares que têm um placar com opção de virar a tela pra mesa.
struct ModeTogglePill: View {
    @Binding var isTableMode: Bool

    var body: some View {
        HStack(spacing: 2) {
            segment(label: "Normal", systemImage: "rectangle.portrait", isActive: !isTableMode) {
                isTableMode = false
            }
            segment(label: "Mesa", systemImage: "rectangle.landscape.rotate", isActive: isTableMode) {
                isTableMode = true
            }
        }
        .padding(3)
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
    }

    private func segment(label: String, systemImage: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(label)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(isActive ? .black : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isActive ? Color.white : Color.clear)
            .clipShape(Capsule())
        }
        .disabled(isActive)
    }
}
