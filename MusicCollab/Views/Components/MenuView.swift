import SwiftUI

/**
 # MenuView
 
 A modular component for the sequencer's side menu containing room information and actions.
 
 ## Features
 - Room header with participant count
 - Jam block functionality
 - Leave room action
 - Clean, organized menu layout
 - Dismissible modal presentation
 
 ## Usage
 ```swift
 MenuView(
     room: room,
     onLeaveRoom: { /* handle leave room */ }
 )
 ```
 
 ## Parameters
 - `room`: Room object containing room information
 - `onLeaveRoom`: Callback closure for leave room action
 
 ## Menu Items
 - **Room Header**: Displays room name and participant count
 - **Jam Block**: Placeholder for future jam functionality
 - **Leave Room**: Button to exit the current room
 */
struct MenuView: View {
    let room: Room
    let onLeaveRoom: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Room Header
                RoomHeaderView(room: room)
                
                // Menu Items
                VStack(spacing: 16) {
                    // Jam Block
                    Button {
                        // TODO: Implement jam functionality
                    } label: {
                        HStack {
                            Image(systemName: "music.note")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Jam Block")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    // Leave Room
                    Button {
                        onLeaveRoom()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Leave Room")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/**
 # RoomHeaderView
 
 A component for displaying room information in the menu.
 
 ## Features
 - Room name display
 - Participant count with icon
 - Clean, informative layout
 */
struct RoomHeaderView: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(room.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.secondary)
                
                Text("\(room.participantCount) participants")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(
            room: Room(name: "Preview Room", participantCount: 3),
            onLeaveRoom: { print("Leave room tapped") }
        )
        .previewDisplayName("Menu View")
        
        RoomHeaderView(room: Room(name: "Test Room", participantCount: 5))
            .previewDisplayName("Room Header")
    }
}
