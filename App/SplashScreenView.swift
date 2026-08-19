//
//  SplashScreenView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 19/08/26.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(.teamDraftIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                    )

                Text("TeamDraft")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.blue)
            }

            Spacer()

            VStack(spacing: 10) {
                Text("Times equilibrados, jogos melhores")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == 2 ? Color.blue : Color.blue.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    SplashScreenView()
}
