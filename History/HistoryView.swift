//
//  HistoryView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 15/08/26.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                Text("Em breve")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("O histórico das suas sessões vai aparecer aqui")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Spacer()
            }
            .navigationTitle("Histórico")
        }
    }
}

#Preview {
    HistoryView()
}
