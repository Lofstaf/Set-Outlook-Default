//
//  ContentView.swift
//  Set Outlook Default
//
//  Created by Micke on 2025-09-15.
//

import SwiftUI

final class DefaultSetterModel: ObservableObject {
    @Published var statusLines: [String] = []
    @Published var busy = false

    func log(_ s: String) { DispatchQueue.main.async { self.statusLines.append(s) } }

    @MainActor
    func applyDefaults() async {
        guard !busy else { return }
        busy = true
        statusLines.removeAll()

        log("— Outlook Default Setter —")

        guard let outlookID = OutlookDefaults.outlookBundleID() else {
            log("❌ Couldn’t find Microsoft Outlook on this Mac. Please install Outlook and try again.")
            busy = false
            return
        }
        log("Found Outlook: \(outlookID)")

        do {
            try OutlookDefaults.setMailto(bundleID: outlookID)
            log("✅ Set Outlook as default handler for mailto: links")
        } catch {
            log("❌ Failed to set mailto handler: \(error.localizedDescription)")
        }

        do {
            try OutlookDefaults.setEMLHandlers(bundleID: outlookID)
        } catch {
            log("❌ Failed to set .eml/message handlers: \(error.localizedDescription)")
        }

        // Show current
        let current = OutlookDefaults.currentHandlers()
        if let m = current.mailto { log("Current mailto handler: \(m)") }
        if let e = current.eml { log("Current .eml handler: \(e)") }
        if let r = current.rfc822 { log("Current message/rfc822 handler: \(r)") }

        log("")
        log("If Finder doesn’t reflect the change immediately for .eml files:")
        log("Right‑click any .eml → Get Info → Open With → Microsoft Outlook → Change All…")

        busy = false
    }
}

struct ContentView: View {
    @EnvironmentObject private var model: DefaultSetterModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Make Outlook Default")
                .font(.title)
                .fontWeight(.semibold)

            Text("This sets Microsoft Outlook as default for mailto: links and .eml files.")
                .foregroundStyle(.secondary)

            HStack {
                Button(action: { Task { await model.applyDefaults() } }) {
                    if model.busy { ProgressView().controlSize(.small) }
                    Text(model.busy ? "Working…" : "Make Outlook Default")
                }
                .keyboardShortcut(.defaultAction)
                .disabled(model.busy)

                Spacer()
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(model.statusLines.enumerated()), id: \.offset) { _, line in
                        Text(line).font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 160)
        }
        .padding(20)
        .frame(width: 520)
    }
}
