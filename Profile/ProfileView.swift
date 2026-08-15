//
//  ProfileView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 15/08/26.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                Text("Em breve")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("Suas configurações de perfil vão aparecer aqui")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Spacer()
            }
            .navigationTitle("Perfil")
        }
    }
}

#Preview {
    ProfileView()
}
