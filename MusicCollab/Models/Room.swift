import Foundation

struct Room: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let createdAt: Date
    let participantCount: Int
    let isActive: Bool
    
    init(id: String = UUID().uuidString, name: String, createdAt: Date = Date(), participantCount: Int = 0, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.participantCount = participantCount
        self.isActive = isActive
    }
}

// MARK: - Mock Data
extension Room {
    static let mockRooms: [Room] = [
        Room(name: "Jazz Jam Session", participantCount: 3),
        Room(name: "Electronic Beats", participantCount: 2),
        Room(name: "Acoustic Folk", participantCount: 1),
        Room(name: "Rock & Roll", participantCount: 4),
        Room(name: "Hip Hop Studio", participantCount: 2)
    ]
}
