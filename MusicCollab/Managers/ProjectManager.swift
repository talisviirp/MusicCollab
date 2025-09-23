// filepath: /Users/talisviirpalu/coding/MusicCollab/MusicCollab/Managers/ProjectManager.swift
import Foundation

final class ProjectManager: ObservableObject {
    static let shared = ProjectManager()

    @Published var currentProjectName: String? = nil

    private init() {}

    func createNewProject(named name: String) {
        currentProjectName = name
        print("Project created: \(name)")
    }
}

