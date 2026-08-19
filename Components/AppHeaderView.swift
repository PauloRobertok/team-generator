//
//  AppHeaderView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI

struct AppHeaderView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(.teamDraftIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text("TeamDraft")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.blue)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

#Preview {
    AppHeaderView()
}
