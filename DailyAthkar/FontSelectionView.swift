//
//  FontSelectionView.swift
//  DailyAthkar
//
//  Font picker with size stepper
//

import SwiftUI

struct FontSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFont: UIFont?
    @State private var fontSize: Double = 22

    private var fonts: [(name: String, font: UIFont)] {
        if appState.isArabic {
            return [
                ("noorehira", UIFont(name: "noorehira", size: 23)!),
                ("AlQalamQuranMajeed1", UIFont(name: "AlQalamQuranMajeed1", size: 24)!),
                ("Amiri-Regular", UIFont(name: "Amiri-Regular", size: 24)!),
                ("DroidArabicKufi", UIFont(name: "DroidArabicKufi", size: 20)!),
                ("DroidArabicNaskh", UIFont(name: "DroidArabicNaskh", size: 21)!),
                ("Lateef", UIFont(name: "Lateef", size: 26)!),
                ("Mohammad-Bold-Art-2", UIFont(name: "Mohammad-Bold-Art-2", size: 22)!),
                ("_PDMS_Saleem_QuranFont", UIFont(name: "_PDMS_Saleem_QuranFont", size: 30)!),
                ("Scheherazade", UIFont(name: "Scheherazade", size: 32)!),
            ]
        } else {
            return [
                ("DroidSans", UIFont(name: "DroidSans", size: 20)!),
                ("DroidSerif", UIFont(name: "DroidSerif", size: 20)!),
                ("DroidSerif-Italic", UIFont(name: "DroidSerif-Italic", size: 20)!),
                ("OpenSans", UIFont(name: "OpenSans", size: 20)!),
                ("OpenSans-Italic", UIFont(name: "OpenSans-Italic", size: 20)!),
                ("OpenSans-Light", UIFont(name: "OpenSans-Light", size: 20)!),
                ("OpenSansLight-Italic", UIFont(name: "OpenSansLight-Italic", size: 20)!),
                ("Roboto-Thin", UIFont(name: "Roboto-Thin", size: 20)!),
                ("Ubuntu-Light", UIFont(name: "Ubuntu-Light", size: 20)!),
                ("Ubuntu-LightItalic", UIFont(name: "Ubuntu-LightItalic", size: 20)!),
            ]
        }
    }

    private var previewText: String {
        appState.isArabic
            ? "هكذا سيبدو النص النهائي \nوهذا سطر آخر لضمان سهولة القراءة"
            : "This is how the text will appear.\nAnd this is another line to make sure text is legible"
    }

    private var tapText: String {
        appState.isArabic ? "اضغط لتجربة هذا الخط" : "Tap to try this font"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Preview
            VStack(spacing: 12) {
                Text(previewText)
                    .font(previewFont)
                    .multilineTextAlignment(appState.isArabic ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: appState.isArabic ? .trailing : .leading)
                    .padding()

                // Size stepper
                HStack {
                    Text("Size: \(Int(fontSize))")
                    Stepper("", value: $fontSize, in: 12...60, step: 1)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)

            Divider()

            // Font list
            List(fonts, id: \.name) { item in
                Button {
                    selectedFont = item.font
                    fontSize = Double(item.font.pointSize)
                } label: {
                    Text(tapText)
                        .font(Font.custom(item.name, size: CGFloat(fontSize)))
                        .foregroundStyle(.primary)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle(appState.localized("font"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(appState.localized("save")) {
                    saveSelection()
                    dismiss()
                }
            }
        }
        .onAppear {
            let current = appState.savedFont
            selectedFont = current
            fontSize = Double(current.pointSize)
        }
    }

    private var previewFont: Font {
        if let sel = selectedFont {
            return Font.custom(sel.fontName, size: fontSize)
        }
        return appState.contentFont
    }

    private func saveSelection() {
        guard let font = selectedFont else { return }
        let adjusted = font.withSize(CGFloat(fontSize))
        appState.saveFont(adjusted)
    }
}
