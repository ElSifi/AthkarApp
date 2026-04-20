# DailyAthkar - Next Steps

## Completed Migration
- [x] SwiftUI app entry point (`@main`, `UIApplicationDelegateAdaptor`)
- [x] All screens ported: Home, Section Content, Settings, Font Selection
- [x] Models & services ported (`AthkarModels`, `AthkarLoader`)
- [x] Audio playback with `AVAudioPlayer` + `MPRemoteCommandCenter`
- [x] Democratic Features (Firebase Realtime Database)
- [x] Share feature using SwiftUI `ImageRenderer`
- [x] Local notifications using native `UNUserNotificationCenter`
- [x] CocoaPods → SPM (Firebase 11.x, Siren 6.x)
- [x] Deployment target: iOS 17.0
- [x] Meezan stubbed (login removed, invite tracking preserved)
- [x] In-app language toggle (AR/EN) with RTL support

## Remaining Work

### High Priority
1. **OneSignal → Native APNs**: OneSignal SDK removed. Re-add via SPM or migrate to native push notifications with APNs. The `OneSignalNotificationServiceExtension` target is stubbed.
2. **Meezan Revival**: Phone auth login was removed (depended on `FirebasePhoneAuthUI`). Options:
   - Use Firebase phone auth directly (without UI library)
   - Use `AuthenticationServices` (Sign in with Apple)
   - Re-add `FirebaseAuthUI` via SPM
3. **String Catalogs**: Convert `Localizable.strings` (en + ar) to `.xcstrings` format for modern localization workflow.

### Medium Priority
4. **On-Demand Audio Download**: Currently all audio bundled in app (~large). Consider hosting on Firebase Storage and downloading on demand.
5. **Test Suite**: Old BDD tests (Cucumberish) and unit tests reference deleted UIKit code. Write new tests with Swift Testing framework.
6. **Dynamic Links Deprecation**: Firebase Dynamic Links is deprecated. Migrate invite links to Firebase Hosting + App Links / Universal Links.
7. **RecaptchaInterop Warning**: Build shows modulemap warnings for `RecaptchaInterop` from Firebase Auth. This is a known Firebase SPM issue that typically resolves in future Firebase releases.

### Low Priority
8. **SwiftData**: Consider migrating from `db.json` + UserDefaults to SwiftData for offline favorites / reading progress.
9. **WidgetKit**: Add lock screen / home screen widgets for daily athkar.
10. **App Intents**: Add Siri Shortcuts for quick athkar access.
11. **iOS 26 Features**: When targeting iOS 26, leverage new SwiftUI APIs (Liquid Glass, etc.).

## Architecture Notes
- **State Management**: `AppState` as `ObservableObject` with `@AppStorage` for persistence
- **Navigation**: `NavigationStack` with `fullScreenCover` for section content
- **Localization**: Bundle-based localization via `AppState.localized(_:)` for in-app language switching
- **Audio**: `AudioPlayer` ObservableObject wrapping `AVAudioPlayer`
- **Dependencies**: Firebase (Auth, Firestore, Database, DynamicLinks, Analytics), Siren — all via SPM
