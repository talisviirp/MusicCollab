import Foundation
import Combine

class RoomService: ObservableObject {
    static let shared = RoomService()
    
    @Published var rooms: [Room] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        // Load mock data initially
        loadMockRooms()
    }
    
    // MARK: - API Methods
    
    func fetchRooms() {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadMockRooms()
            self.isLoading = false
        }
    }
    
    func createRoom(name: String) -> Room {
        let newRoom = Room(name: name, participantCount: 1)
        rooms.append(newRoom)
        return newRoom
    }
    
    func joinRoom(roomId: String) -> Bool {
        guard let roomIndex = rooms.firstIndex(where: { $0.id == roomId }) else {
            errorMessage = "Room not found"
            return false
        }
        
        rooms[roomIndex] = Room(
            id: rooms[roomIndex].id,
            name: rooms[roomIndex].name,
            createdAt: rooms[roomIndex].createdAt,
            participantCount: rooms[roomIndex].participantCount + 1,
            isActive: true
        )
        return true
    }
    
    func leaveRoom(roomId: String) -> Bool {
        guard let roomIndex = rooms.firstIndex(where: { $0.id == roomId }) else {
            errorMessage = "Room not found"
            return false
        }
        
        let newCount = max(0, rooms[roomIndex].participantCount - 1)
        rooms[roomIndex] = Room(
            id: rooms[roomIndex].id,
            name: rooms[roomIndex].name,
            createdAt: rooms[roomIndex].createdAt,
            participantCount: newCount,
            isActive: newCount > 0
        )
        return true
    }
    
    // MARK: - Private Methods
    
    private func loadMockRooms() {
        rooms = Room.mockRooms
    }
}
