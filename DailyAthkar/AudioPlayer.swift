//
//  AudioPlayer.swift
//  DailyAthkar
//
//  AVAudioPlayer wrapper with MPRemoteCommandCenter support
//

import AVFoundation
import MediaPlayer

class AudioPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentIndex: Int = 0

    private var player: AVAudioPlayer?
    private var items: [(path: String, title: String)] = []
    private var delegate: AudioPlayerDelegateHandler?

    func load(items: [(path: String, title: String)], startAt index: Int = 0) {
        self.items = items
        currentIndex = index
        configureAudioSession()
        setupRemoteCommands()
    }

    func play(at index: Int? = nil) {
        let idx = index ?? currentIndex
        guard items.indices.contains(idx) else { return }
        currentIndex = idx

        let url = URL(fileURLWithPath: items[idx].path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            delegate = AudioPlayerDelegateHandler { [weak self] in
                self?.playNext()
            }
            player?.delegate = delegate
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            updateNowPlaying()
        } catch {
            print("Audio error: \(error)")
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { play() }
    }

    func playNext() {
        let next = currentIndex + 1
        if items.indices.contains(next) {
            play(at: next)
        } else {
            stop()
        }
    }

    func playPrevious() {
        let prev = currentIndex - 1
        if items.indices.contains(prev) {
            play(at: prev)
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            self?.play(); return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause(); return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext(); return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPrevious(); return .success
        }
    }

    private func updateNowPlaying() {
        guard items.indices.contains(currentIndex) else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: items[currentIndex].title,
            MPMediaItemPropertyArtist: "DailyAthkar"
        ]
        if let duration = player?.duration {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

private class AudioPlayerDelegateHandler: NSObject, AVAudioPlayerDelegate {
    let onFinish: () -> Void
    init(onFinish: @escaping () -> Void) { self.onFinish = onFinish }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        onFinish()
    }
}
