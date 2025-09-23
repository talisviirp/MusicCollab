import SwiftUI

struct RoomListView: View {
    @StateObject private var roomService = RoomService.shared
    @State private var showingCreateRoom = false
    let onRoomSelected: (Room) -> Void

    var body: some View {
        NavigationView {
            VStack {
                if roomService.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading rooms...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if roomService.rooms.isEmpty {
                    EmptyRoomsView {
                        showingCreateRoom = true
                    }
                } else {
                    List(roomService.rooms) { room in
                        RoomRowView(room: room) {
                            roomService.joinRoom(roomId: room.id)
                            onRoomSelected(room)
                        }
                    }
                    .refreshable {
                        roomService.fetchRooms()
                    }
                }
            }
            .navigationTitle("Music Rooms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateRoom = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateRoom) {
                CreateRoomView(roomService: roomService)
            }
        }
        .onAppear {
            roomService.fetchRooms()
        }
    }
}

struct EmptyRoomsView: View {
    let onCreateRoom: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                Text("No Rooms Yet")
                    .font(.title.bold())
                
                Text("Create your first music room and start collaborating with friends!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onCreateRoom) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Room")
                        .fontWeight(.semibold)
                }
                .font(.title3)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RoomRowView: View {
    let room: Room
    let onJoin: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Room Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "music.note.house.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            
            // Room Info
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text("\(room.participantCount) participant\(room.participantCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if room.isActive {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            Spacer()
            
            // Join Button
            Button("Join") {
                onJoin()
            }
            .buttonStyle(.borderedProminent)
            .disabled(room.participantCount >= 8) // Max participants
        }
        .padding(.vertical, 8)
    }
}

struct CreateRoomView: View {
    @ObservedObject var roomService: RoomService
    @Environment(\.dismiss) private var dismiss
    @State private var roomName = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Create New Room")
                        .font(.title.bold())
                    
                    Text("Give your room a memorable name")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Input Section
                VStack(spacing: 20) {
                    TextField("Room name", text: $roomName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .focused($isTextFieldFocused)
                        .onAppear {
                            isTextFieldFocused = true
                        }
                    
                    if let errorMessage = roomService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Create") {
                        createRoom()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationTitle("New Room")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
    
    private func createRoom() {
        let trimmedName = roomName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        _ = roomService.createRoom(name: trimmedName)
        dismiss()
    }
}

// MARK: - Previews
struct RoomListView_Previews: PreviewProvider {
    static var previews: some View {
        RoomListView { room in
            print("Room selected: \(room.name)")
        }
        .previewDisplayName("Room List")
    }
}

struct EmptyRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyRoomsView {
            print("Create room tapped")
        }
        .previewDisplayName("Empty Rooms")
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView(roomService: RoomService.shared)
            .previewDisplayName("Create Room")
    }
}
