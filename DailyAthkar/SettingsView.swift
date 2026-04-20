//
//  SettingsView.swift
//  DailyAthkar
//
//  Settings screen
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showFeatureRequests = false
    @State private var showLogin = false

    var body: some View {
        List {
            // Language
            Section {
                settingsRow(
                    title: appState.localized("app language"),
                    value: appState.isArabic
                        ? appState.localized("arabic")
                        : appState.localized("english")
                ) {
                    appState.changeLanguage(to: appState.isArabic ? "en" : "ar")
                }
            }

            // Text settings
            Section {
                if appState.isArabic {
                    // Tashkeel
                    Toggle(isOn: Binding(
                        get: { appState.showTashkeel },
                        set: { appState.showTashkeel = $0 }
                    )) {
                        Text("التشكيل")
                    }
                } else {
                    // Translation vs Transliteration
                    settingsRow(
                        title: "Text Mode",
                        value: appState.showTransliteration ? "Transliteration" : "Translation"
                    ) {
                        appState.showTransliteration.toggle()
                    }
                }

                // Font
                NavigationLink {
                    FontSelectionView()
                        .environmentObject(appState)
                } label: {
                    HStack {
                        Text(appState.localized("font"))
                        Spacer()
                        Text(appState.savedFont.fontName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Default mode
                settingsRow(
                    title: appState.localized("text length mode"),
                    value: appState.onlyShortAthkar
                        ? appState.localized("only short athkar")
                        : appState.localized("all athkar")
                ) {
                    appState.onlyShortAthkar.toggle()
                }
            }

            // Actions
            Section {
                // Share the app
                Button {
                    shareApp()
                } label: {
                    Text(appState.localized("share the app"))
                        .foregroundStyle(.primary)
                }

                // Rate
                Button {
                    rateApp()
                } label: {
                    Text(appState.localized("rate the app"))
                        .foregroundStyle(.primary)
                }

                // Contact
                Button {
                    contactDeveloper()
                } label: {
                    Text(appState.localized("contact developer"))
                        .foregroundStyle(.primary)
                }
            }

            // Feature Requests
            Section {
                Button {
                    showFeatureRequests = true
                    appState.didTapAddFeatureBefore = true
                } label: {
                    Text(appState.localized("feature requests"))
                        .foregroundStyle(appState.didTapAddFeatureBefore ? Color.primary : Color.red)
                }
            }

            // Auth
            Section {
                if let user = Auth.auth().currentUser, !user.isAnonymous {
                    Button(role: .destructive) {
                        try? Auth.auth().signOut()
                        dismiss()
                    } label: {
                        Text(appState.localized("log out"))
                    }
                } else {
                    Button {
                        showLogin = true
                    } label: {
                        Text(appState.localized("log in"))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .navigationTitle(appState.localized("settings"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(appState.localized("save")) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showFeatureRequests) {
            NavigationStack {
                DemocraticFeaturesView()
            }
        }
        .sheet(isPresented: $showLogin) {
            MeezanLoginView()
        }
    }

    @ViewBuilder
    private func settingsRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func shareApp() {
        let text = String(format: appState.localized("share message"), "https://apps.apple.com/app/id821664774")
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }

    private func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id821664774") {
            UIApplication.shared.open(url)
        }
    }

    private func contactDeveloper() {
        if let url = URL(string: "mailto:mo@badi3.com") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Meezan Login (stub)
struct MeezanLoginView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .font(.system(size: 60))
                .foregroundStyle(.brown)
            Text("Login")
                .font(.title2)
            Text("Available Soon")
                .foregroundStyle(.secondary)
            Button("OK") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
        }
        .padding()
    }
}
