//
//  MusicCollabApp.swift
//  MusicCollab
//
//  Created by Talis Viirpalu on 06.11.2024.
//

import SwiftUI

#if os(iOS)
@main
struct MusicCollabApp: App {
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
    }

    init() {
        AudioManager.shared.startEngine()
    }
}
#endif
