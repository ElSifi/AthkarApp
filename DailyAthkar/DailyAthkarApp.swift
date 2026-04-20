//
//  DailyAthkarApp.swift
//  DailyAthkar
//
//  Migrated to SwiftUI
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDynamicLinks
import Siren

@main
struct DailyAthkarApp: App {
    @UIApplicationDelegateAdaptor(DAAppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HomeView()
            .environment(\.layoutDirection, appState.isRTL ? .rightToLeft : .leftToRight)
    }
}

class DAAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set Arabic as default language on first launch
        let notFirstOpenKey = "notFirstOpen"
        if !UserDefaults.standard.bool(forKey: notFirstOpenKey) {
            UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
            UserDefaults.standard.set("ar", forKey: "currentLanguageKey")
            UserDefaults.standard.set(true, forKey: notFirstOpenKey)
        }

        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)

        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .default)
        siren.wail()

        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error { print("Anonymous auth error: \(error)") }
            }
        }

        // TODO: Migrate OneSignal to native APNs
        // OneSignal setup was here - re-enable after SPM migration

        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
            guard error == nil, let link = dynamicLink?.url,
                  let components = URLComponents(url: link, resolvingAgainstBaseURL: true),
                  let params = components.queryItems else { return }
            let dict = Dictionary(uniqueKeysWithValues: params.compactMap { item in
                item.value.map { v in (item.name, v) }
            })
            if dict["type"] == "invite", let uid = dict["uid"] {
                Meezan.registerMyInviter(inviterUID: uid)
            }
        }
        return handled
    }
}
