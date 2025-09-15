//
//  Set_Outlook_DefaultApp.swift
//  Set Outlook Default
//
//  Created by Micke on 2025-09-15.
//

import SwiftUI

@main
struct SetOutlookDefaultApp: App {
    @StateObject private var model = DefaultSetterModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .task {
                    // Try automatically on launch
                    await model.applyDefaults()
                }
        }
        .windowResizability(.contentSize)
    }
}
