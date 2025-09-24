# MusicCollab - iOS Music Collaboration App

A real-time music collaboration app built with SwiftUI, featuring a step sequencer, audio mixing, and room-based collaboration.

## 🎵 Features

### Core Sequencer
- **Step Sequencer**: 16-step grid with responsive layout (1x16 landscape, 2x8 portrait)
- **Drum Sounds**: Kick, snare, hi-hat, and hi-hat2 with color-coded selection
- **Tempo Control**: Live BPM adjustment (60-200 BPM) without audio interruption
- **Transport Controls**: Play, pause, and stop with visual state indication

### Audio Mixing
- **Track Mixers**: Individual volume, pan, solo, and mute controls for each track
- **Master Volume**: Global volume control with transport integration
- **Live Pan Indicators**: Real-time pan values with L/R directional display
- **Solo Functionality**: Multiple track soloing with smart audio routing

### Collaboration
- **Room Management**: Create, join, and leave collaboration rooms
- **User Onboarding**: Simple nickname setup and room discovery
- **Real-time Sync**: Shared tempo and pattern synchronization (planned)

## 🏗️ Architecture

### Modular Component System
The app uses a modular architecture with reusable SwiftUI components:

```
Views/
├── Components/           # Reusable UI components
│   ├── TempoControlView.swift
│   ├── TransportControlsView.swift
│   ├── SoundSelectionView.swift
│   ├── StepGridView.swift
│   ├── MenuView.swift
│   └── MixingCenterView.swift
├── SequencerView.swift  # Main sequencer interface
├── RoomListView.swift   # Room discovery and management
├── OnboardingView.swift # User onboarding
└── AppCoordinatorView.swift # App flow coordination
```

### Core Systems
- **AudioManager**: Professional-grade audio engine with real-time threading, pre-allocated buffers, and thread-safe operations
- **SequencerState**: Pattern and step management with real-time updates
- **RoomService**: Room data and collaboration logic
- **AppCoordinatorView**: Application flow management

### Audio Architecture
- **AVAudioEngine**: Core audio processing with player nodes for each sample
- **Real-Time Thread**: High-priority `DispatchQueue` with 2ms precision timing
- **Pre-allocated Buffers**: Zero-latency sample playback using `AVAudioPCMBuffer`
- **Thread-Safe Communication**: Lock-free design with atomic state access
- **Audio Session Management**: Professional configuration with fallback support

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 18.1+
- Swift 5.9+

### Installation
1. Clone the repository
2. Open `MusicCollab.xcodeproj` in Xcode
3. Build and run on iOS Simulator or device

### Dependencies
- **AudioKit**: Audio processing and playback
- **Tonic**: Music theory and note handling
- **Keyboard**: Virtual keyboard interface

## 📱 Usage

### Basic Sequencer Operation
1. **Select a Sound**: Tap one of the colored sound buttons
2. **Add Steps**: Tap circles in the step grid to activate steps
3. **Control Playback**: Use play/pause/stop buttons
4. **Adjust Tempo**: Tap BPM button to open tempo control

### Mixing and Effects
1. **Open Mixer**: Tap the slider icon in the top-right
2. **Adjust Volume**: Use vertical sliders for each track
3. **Control Pan**: Use horizontal pan sliders (-50L to +50R)
4. **Solo Tracks**: Tap 'S' button to solo individual tracks
5. **Mute Tracks**: Tap speaker button to mute tracks

### Room Collaboration
1. **Create Room**: Tap "Create Room" and enter a name
2. **Join Room**: Tap on an existing room to join
3. **Leave Room**: Use the menu (hamburger icon) to leave

## 🎛️ Component Documentation

Each component includes comprehensive documentation:

- **Purpose and Features**: What the component does
- **Usage Examples**: How to use the component
- **Parameters**: Configuration options
- **Dependencies**: Required objects and services
- **Preview Providers**: SwiftUI preview examples

### Audio System Documentation
- **[AudioManager.md](MusicCollab/Managers/AudioManager.md)**: Complete audio engine documentation
- **Real-Time Threading**: Professional audio thread implementation
- **Pre-allocated Buffers**: Zero-latency audio playback system
- **Audio Session Management**: Low-latency configuration with fallback

See individual component files for detailed documentation.

## 🔧 Development

### Quick Reference

#### Audio System
- **AudioManager**: `AudioManager.shared` for all audio operations
- **Thread Safety**: All audio operations run on dedicated thread
- **Sample Playback**: Use `playKick()`, `playSnare()`, `playHiHat()`, `playHiHat2()`
- **Sequencer Control**: `startPlayback()`, `stopPlayback()`, `pausePlayback()`
- **Volume Control**: `updateMasterVolume(_:)` for global volume

#### Component Integration
- **Audio Operations**: Always go through AudioManager
- **UI Updates**: Use `@ObservedObject` for AudioManager state
- **Thread Safety**: UI updates happen on main thread automatically

### Adding New Components
1. Create new Swift file in `Views/Components/`
2. Follow existing documentation patterns
3. Add SwiftUI preview providers
4. Update component README
5. Test in isolation and integration

### State Management
- Use `@ObservedObject` for shared state
- Use `@State` for local component state
- Use `@StateObject` for component-owned objects
- Propagate changes through bindings

### Audio Integration
- **Real-Time Audio Threading**: Dedicated high-priority audio thread with 2ms precision timing
- **Pre-allocated Buffers**: All samples pre-loaded into `AVAudioPCMBuffer` for zero-latency playback
- **Thread-Safe Operations**: Audio operations isolated from main thread to prevent UI blocking
- **Professional Audio Session**: Configured for low-latency playback with fallback support
- **Route Change Handling**: Automatic recovery from headphone/device changes
- **Real-Time Safety**: No memory allocations or blocking operations in audio thread

## 🎨 UI/UX Design

### Responsive Layout
- **Landscape**: Horizontal layout with 1x16 step grid
- **Portrait**: Vertical layout with 2x8 step grid
- **Adaptive**: Components adjust to screen size

### Color Coding
- **Kick**: Red
- **Snare**: Blue
- **Hi-Hat**: Green
- **Hi-Hat2**: Purple
- **Active Steps**: Match selected sound color

### Visual Feedback
- **Playing Steps**: Pulsing animation
- **Selected Sound**: White border highlight
- **Solo Tracks**: Yellow button state
- **Muted Tracks**: Red button state

## 🚧 Roadmap

### Phase 1 - Core Features ✅
- [x] Basic sequencer functionality
- [x] Professional audio engine with real-time threading
- [x] Pre-allocated audio buffers for zero-latency playback
- [x] Thread-safe audio operations
- [x] Audio session management with fallback support
- [x] Responsive UI design
- [x] Room management

### Phase 2 - Collaboration (In Progress)
- [ ] Real-time pattern synchronization
- [ ] User presence indicators
- [ ] Chat functionality
- [ ] Pattern sharing

### Phase 3 - Advanced Features
- [ ] Audio effects and filters
- [ ] Pattern recording and playback
- [ ] MIDI input support
- [ ] Export functionality

### Phase 4 - Polish
- [ ] Accessibility improvements
- [ ] Performance optimization
- [ ] Advanced theming
- [ ] Tutorial system

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the coding standards
4. Add tests for new features
5. Update documentation
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **AudioKit** for audio processing capabilities
- **SwiftUI** for modern UI development
- **Apple** for iOS development tools and frameworks

---

**MusicCollab** - Making music together, one step at a time. 🎵
