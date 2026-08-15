//
//  AppHeaderView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI

struct AppHeaderView: View {
    var body: some View {
        HStack {
            Image(.teamDraftIcon)
                .font(.title)

            Text("Drafter")
                .foregroundStyle(.blue)
                .fontWeight(.bold)
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

#Preview {
    AppHeaderView()
}
