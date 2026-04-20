//
//  HomeView.swift
//  DailyAthkar
//
//  Home screen showing all Athkar sections
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var sections: [AthkarSection] = []
    @State private var bgImageName = ["bg1", "bg2", "bg3", "bg4"].randomElement()!
    @State private var showSettings = false
    @State private var selectedSection: (section: AthkarSection, onlyBrief: Bool)?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Image(bgImageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Blurred list
                List {
                    ForEach(sections) { section in
                        SectionRow(
                            section: section,
                            isArabic: appState.isArabic,
                            menuFont: appState.menuFont,
                            onTapFull: {
                                selectedSection = (section, false)
                            }
                        )
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .padding(.vertical, 4)
                        )
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                selectedSection = (section, false)
                            } label: {
                                Label(appState.localized("all athkar"), systemImage: "text.justify")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                selectedSection = (section, true)
                            } label: {
                                Label(appState.localized("only short athkar"), systemImage: "text.badge.checkmark")
                            }
                            .tint(.green)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
            }
            .navigationTitle("الأذكار اليومية")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image("settingsIcon")
                            .renderingMode(.template)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    // Meezan stub
                    Button {} label: {
                        Image("meezanIcon")
                            .renderingMode(.template)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .disabled(true)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView()
                        .environmentObject(appState)
                }
            }
            .fullScreenCover(item: Binding(
                get: { selectedSection.map { SectionSelection(section: $0.section, onlyBrief: $0.onlyBrief) } },
                set: { if $0 == nil { selectedSection = nil } }
            )) { selection in
                NavigationStack {
                    SectionContentView(
                        section: selection.section,
                        onlyBrief: selection.onlyBrief
                    )
                    .environmentObject(appState)
                }
            }
        }
        .onAppear {
            sections = AthkarLoader.loadSections()
        }
    }
}

struct SectionSelection: Identifiable {
    let id = UUID()
    let section: AthkarSection
    let onlyBrief: Bool
}

struct SectionRow: View {
    let section: AthkarSection
    let isArabic: Bool
    let menuFont: Font
    let onTapFull: () -> Void

    var body: some View {
        Button(action: onTapFull) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.brown.opacity(0.7))
                        .frame(width: 50, height: 50)
                    Image(section.stringID)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                }

                // Title
                Text(section.localizedName(isArabic: isArabic))
                    .font(menuFont)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(isArabic ? .trailing : .leading)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
