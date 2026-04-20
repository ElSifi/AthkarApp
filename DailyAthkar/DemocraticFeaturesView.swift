//
//  DemocraticFeaturesView.swift
//  DailyAthkar
//
//  Feature requests with voting via Firebase Realtime Database
//

import SwiftUI
import Firebase

struct DemocraticFeaturesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var features: [DFFeature] = []
    @State private var showAddFeature = false

    private let containerTitle: String = {
        let bundleID = (Bundle.main.bundleIdentifier ?? "app").replacingOccurrences(of: ".", with: "_")
        return "\(bundleID)_democracy"
    }()

    private var userID: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    var body: some View {
        List(features) { feature in
            Button {
                toggleVote(for: feature)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title ?? "")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if let details = feature.details, !details.isEmpty {
                            Text(details)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text("\((feature.votes ?? []).count) votes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Feature Requests")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddFeature = true } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { dismiss() }
            }
        }
        .sheet(isPresented: $showAddFeature) {
            AddFeatureView(containerTitle: containerTitle, userID: userID)
        }
        .onAppear { observeFeatures() }
    }

    private func observeFeatures() {
        let ref = Database.database().reference().child(containerTitle)
        ref.observe(.value) { snapshot in
            var list: [DFFeature] = []
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                guard var dict = child.value as? [String: Any] else { continue }
                dict["id"] = child.key
                if let data = try? JSONSerialization.data(withJSONObject: dict),
                   let feature = try? JSONDecoder().decode(DFFeature.self, from: data) {
                    list.append(feature)
                }
            }
            list.sort { ($0.votes ?? []).count > ($1.votes ?? []).count }
            list.removeAll { f in
                if (f.owner ?? "") == userID { return false }
                return !(f.shown ?? false)
            }
            features = list
        }
    }

    private func toggleVote(for feature: DFFeature) {
        guard let id = feature.id else { return }
        let ref = Database.database().reference().child(containerTitle).child(id)
        var votes = feature.votes ?? []
        if votes.contains(userID) {
            votes.removeAll { $0 == userID }
        } else {
            votes.append(userID)
        }
        votes = Array(Set(votes))
        ref.updateChildValues(["votes": votes])
    }
}

// MARK: - Add Feature

struct AddFeatureView: View {
    @Environment(\.dismiss) private var dismiss
    let containerTitle: String
    let userID: String

    @State private var title = ""
    @State private var details = ""
    @State private var shake = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Feature title", text: $title)
                        .offset(x: shake ? -5 : 0)
                        .animation(shake ? .default.repeatCount(3, autoreverses: true).speed(6) : .default, value: shake)
                }
                Section("Details") {
                    TextEditor(text: $details)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("New Feature")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { submit() }
                }
            }
        }
    }

    private func submit() {
        guard title.count >= 5 else {
            shake.toggle()
            return
        }
        let feature: [String: Any] = [
            "title": title,
            "details": details,
            "votes": [userID],
            "owner": userID,
            "shown": false
        ]
        Database.database().reference()
            .child(containerTitle)
            .childByAutoId()
            .setValue(feature)
        dismiss()
    }
}

// MARK: - Model

struct DFFeature: Codable, Identifiable {
    var id: String?
    var details, title, owner: String?
    var votes: [String]?
    var shown: Bool?
    var status: String?
}
