//
//  SectionContentView.swift
//  DailyAthkar
//
//  Full Athkar reading experience
//

import SwiftUI
import StoreKit

struct SectionContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var audioPlayer = AudioPlayer()
    @Environment(\.dismiss) private var dismiss

    let section: AthkarSection
    let onlyBrief: Bool

    @State private var athkarList: [ThikrItem] = []
    @State private var shareThikr: ThikrItem?

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    ForEach($athkarList) { $item in
                        ThikrRow(
                            item: $item,
                            appState: appState,
                            onShare: { shareThikr = item },
                            onPlaySound: { playSound(for: item) }
                        )
                        .id(item.thikr.zPk)
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .leading) {
                            Button {
                                playSound(for: item)
                            } label: {
                                Label(appState.localized("play"), systemImage: "play.fill")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                shareThikr = item
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onChange(of: audioPlayer.currentIndex) { _, newIndex in
                    if let item = athkarList[safe: newIndex] {
                        withAnimation {
                            proxy.scrollTo(item.thikr.zPk, anchor: .center)
                        }
                    }
                }
            }

            // Playback bar
            PlaybackBar(
                audioPlayer: audioPlayer,
                appState: appState
            )
        }
        .background {
            Image(["bg1", "bg2", "bg3", "bg4"].randomElement()!)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(.ultraThinMaterial)
        }
        .navigationTitle(section.localizedName(isArabic: appState.isArabic))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .sheet(item: $shareThikr) { item in
            ShareSheet(thikrItem: item, sectionName: section.localizedName(isArabic: appState.isArabic), appState: appState)
        }
        .onAppear {
            loadAthkar()
            loadAudioItems()
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }

    private func loadAthkar() {
        let filtered = onlyBrief
            ? section.content.filter(\.scriptMode)
            : section.content
        athkarList = filtered.map { ThikrItem(thikr: $0) }
    }

    private func loadAudioItems() {
        let items: [(path: String, title: String)] = athkarList.compactMap { item in
            guard let path = item.thikr.soundFilePath(sectionID: section.stringID) else { return nil }
            return (path, item.localizedText(appState: appState))
        }
        audioPlayer.load(items: items)
    }

    private func playSound(for item: ThikrItem) {
        guard let idx = athkarList.firstIndex(where: { $0.thikr.zPk == item.thikr.zPk }) else { return }
        // Find the audio index (may differ if some thikr have no audio)
        var audioIdx = 0
        for i in 0..<idx {
            if athkarList[i].thikr.soundFilePath(sectionID: section.stringID) != nil {
                audioIdx += 1
            }
        }
        audioPlayer.play(at: audioIdx)
    }
}

// MARK: - ThikrItem

struct ThikrItem: Identifiable {
    let id = UUID()
    let thikr: Thikr
    var currentCount: Int = 0

    var isComplete: Bool { currentCount >= thikr.repeatTimes }

    func localizedText(appState: AppState) -> String {
        thikr.localizedText(
            isArabic: appState.isArabic,
            showTashkeel: appState.showTashkeel,
            showTransliteration: appState.showTransliteration,
            fontName: appState.savedFont.fontName
        )
    }
}

// MARK: - ThikrRow

struct ThikrRow: View {
    @Binding var item: ThikrItem
    let appState: AppState
    let onShare: () -> Void
    let onPlaySound: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main text
            Text(item.localizedText(appState: appState))
                .font(appState.contentFont)
                .foregroundStyle(item.isComplete ? .secondary : .primary)
                .multilineTextAlignment(appState.isArabic ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: appState.isArabic ? .trailing : .leading)

            // Repeat counter
            HStack {
                if item.thikr.repeatTimes > 1 {
                    Text("\(item.currentCount) \(appState.localized("of")) \(item.thikr.repeatTimes)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if item.thikr.soundFilePath(sectionID: "") != nil || !item.thikr.thikrTitle.isEmpty {
                    Button(action: onPlaySound) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundStyle(.brown)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            guard !item.isComplete else { return }
            item.currentCount += 1
            if item.isComplete {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                // Check if all complete → prompt for review
                requestReviewIfNeeded()
            }
        }
    }

    private func requestReviewIfNeeded() {
        // Only prompt occasionally
        let key = "reviewRequestCount"
        var count = UserDefaults.standard.integer(forKey: key)
        count += 1
        UserDefaults.standard.set(count, forKey: key)
        if count % 5 == 0 {
            if let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene }).first {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

// MARK: - PlaybackBar

struct PlaybackBar: View {
    @ObservedObject var audioPlayer: AudioPlayer
    let appState: AppState

    var body: some View {
        HStack(spacing: 24) {
            Button(action: audioPlayer.playPrevious) {
                Image(systemName: "backward.fill")
                    .font(.title2)
            }

            Button(action: audioPlayer.togglePlayPause) {
                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title)
            }

            Button(action: audioPlayer.playNext) {
                Image(systemName: "forward.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(.white)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Collection safe subscript
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
