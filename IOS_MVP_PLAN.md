# Music Collaboration iOS App MVP Plan

## Overview

This document outlines the step-by-step MVP plan for building an iOS client application that is fully compatible with
the Music Collaboration NestJS backend service. The app will allow users to create and join rooms, collaborate on
sequencer patterns in real time, and interact with other users using WebSockets.

---

## 1. Core Features (MVP)

### A. User Management

- [ ] User can enter a nickname and create a temporary user profile (no authentication required)
- [ ] User ID is stored locally for session persistence

### B. Room Management

- [ ] List all available rooms (GET /rooms)
- [ ] Create a new room (POST /rooms/create)
- [ ] Join a room (POST /rooms/join/:roomId)
- [ ] Leave a room (POST /rooms/leave/:roomId)
- [ ] View room details (GET /rooms/:roomId)

### C. Sequencer Collaboration

- [ ] Connect to the backend WebSocket gateway (namespace: /sequencer)
- [ ] Receive and display the current sequencer state for the room
- [ ] Start/stop the sequencer (emit 'start'/'stop' events)
- [ ] Adjust BPM (emit 'set_bpm' event)
- [ ] Add/remove sounds from steps (emit 'update_step' event)
- [ ] Receive real-time updates from other users in the room

### D. UI/UX

- [ ] Simple onboarding: enter nickname, create/join room
- [ ] Room lobby: show users in the room, sequencer controls, and pattern grid
- [ ] Sequencer grid: 16 steps, each can be toggled on/off and assigned a sound
- [ ] Real-time feedback for sequencer state changes

---

## 2. Technical Stack

- **Language:** Swift
- **UI Framework:** SwiftUI (recommended for rapid MVP development)
- **Networking:** URLSession for REST, [Socket.IO-Client-Swift](https://github.com/socketio/socket.io-client-swift) for
  WebSockets
- **State Management:** ObservableObject/ViewModel pattern
- **Persistence:** UserDefaults for user ID and nickname

---

## 3. Step-by-Step Execution Plan

1. **Project Setup**
    - Initialize SwiftUI project
    - Add dependencies (Socket.IO-Client-Swift via Swift Package Manager)
2. **User Onboarding**
    - Nickname entry screen
    - Create user via POST /rooms/user
    - Store userId and nickname in UserDefaults
3. **Room List & Creation**
    - Fetch and display rooms (GET /rooms)
    - Create room (POST /rooms/create)
    - Join/leave room endpoints
4. **Room Lobby & Sequencer**
    - Connect to WebSocket on room join
    - Display sequencer state and controls
    - Implement sequencer grid UI
    - Handle start/stop, BPM, and step updates via WebSocket
5. **Real-Time Collaboration**
    - Listen for sequencer_state events and update UI
    - Broadcast user actions to backend
6. **Testing & Validation**
    - Test all flows with backend (room creation, join/leave, sequencer sync)
    - Handle error states (e.g., room not found, connection lost)

---

## 4. Future Improvements (Post-MVP)

- User authentication and persistent profiles
- Audio playback for sequencer steps
- Advanced sequencer features (patterns, effects, etc.)
- Push notifications for invites or room activity
- Improved UI/UX and animations

---

_Last updated: 2025-09-20_

