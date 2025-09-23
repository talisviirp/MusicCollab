// filepath: /Users/talisviirpalu/coding/MusicCollab/MusicCollab/Managers/CollaborationManager.swift
import Foundation

final class CollaborationManager: ObservableObject {
    static let shared = CollaborationManager()

    @Published var connectedRoomId: String? = nil

    private init() {}

    func connect(to roomId: String) {
        connectedRoomId = roomId
        print("Connected to room: \(roomId)")
    }

    func disconnect() {
        print("Disconnected from room: \(connectedRoomId ?? "-")")
        connectedRoomId = nil
    }
}

