//
//  RootTabView.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 15/08/26.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            GroupsView()
                .tabItem {
                    Label("Groups", systemImage: "person.2.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(PreviewContainer.sample)
}
