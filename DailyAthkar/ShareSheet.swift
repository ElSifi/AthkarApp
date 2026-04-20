//
//  ShareSheet.swift
//  DailyAthkar
//
//  Share image generation and sharing
//

import SwiftUI

struct ShareSheet: View {
    let thikrItem: ThikrItem
    let sectionName: String
    let appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                shareCardView
                    .padding()

                Button {
                    shareImage()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var shareCardView: some View {
        VStack(spacing: 16) {
            Text(sectionName)
                .font(.headline)
                .foregroundStyle(.brown)

            Text(thikrItem.localizedText(appState: appState))
                .font(appState.contentFont)
                .multilineTextAlignment(appState.isArabic ? .trailing : .leading)
                .frame(maxWidth: .infinity, alignment: appState.isArabic ? .trailing : .leading)

            Divider()

            Text("الأذكار اليومية - DailyAthkar")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }

    @MainActor
    private func shareImage() {
        let renderer = ImageRenderer(content: shareCardView.frame(width: 340))
        renderer.scale = UIScreen.main.scale
        guard let image = renderer.uiImage else { return }

        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
}
