# Sequencer Components

This directory contains modular, reusable components for the MusicCollab sequencer interface. Each component is self-contained with its own documentation and can be used independently or in combination with other components.

## Component Architecture

The sequencer interface is built using a modular architecture where each component has a specific responsibility:

### Core Components

#### 1. TempoControlView.swift
- **TempoButtonView**: Compact tempo display button
- **TempoControlView**: Modal for tempo adjustment
- **Purpose**: BPM control and display
- **Dependencies**: AudioManager

#### 2. TransportControlsView.swift
- **TransportControlsView**: Play/pause/stop controls
- **Purpose**: Sequencer playback control
- **Dependencies**: AudioManager

#### 3. SoundSelectionView.swift
- **SoundSelectionView**: Drum sound selection interface
- **Purpose**: Sound selection for step placement
- **Dependencies**: None (pure UI)

#### 4. StepGridView.swift
- **StepGridView**: Main sequencer grid
- **StepButton**: Individual step buttons
- **Purpose**: Step sequencing and pattern creation
- **Dependencies**: SequencerState

#### 5. MenuView.swift
- **MenuView**: Side menu with room info and actions
- **RoomHeaderView**: Room information display
- **Purpose**: Room management and navigation
- **Dependencies**: Room model

#### 6. MixingCenterView.swift
- **MixingCenterView**: Main mixing interface
- **TrackMixerView**: Individual track controls
- **MasterVolumeView**: Master volume and transport
- **Purpose**: Audio mixing and track control
- **Dependencies**: SequencerState, AudioManager

## Design Principles

### 1. Modularity
Each component is self-contained and can be used independently. Components communicate through bindings and callbacks rather than direct dependencies.

### 2. Reusability
Components are designed to be reusable across different contexts. They accept configuration through parameters and callbacks.

### 3. Responsiveness
Components adapt to different screen sizes and orientations. Layout parameters control responsive behavior.

### 4. State Management
Components use `@ObservedObject` for shared state and `@State` for local state. State changes are propagated through bindings.

### 5. Documentation
Each component includes comprehensive documentation with:
- Purpose and features
- Usage examples
- Parameter descriptions
- Dependencies

## Usage Patterns

### Basic Component Usage
```swift
// Simple component with binding
TempoButtonView(tempo: $tempo, showingTempoControl: $showingTempo)

// Component with callback
MenuView(room: room) {
    // Handle leave room action
}
```

### Complex Component Usage
```swift
// Component with multiple dependencies
MixingCenterView(sequencerState: sequencerState)
```

## Adding New Components

When adding new components to this directory:

1. **Create a new Swift file** with descriptive name
2. **Include comprehensive documentation** following the existing pattern
3. **Add preview providers** for SwiftUI previews
4. **Follow naming conventions** (ComponentNameView)
5. **Use proper dependency injection** through parameters
6. **Update this README** with component information

## File Structure

```
Components/
├── README.md                    # This file
├── TempoControlView.swift      # Tempo control components
├── TransportControlsView.swift # Playback control components
├── SoundSelectionView.swift    # Sound selection components
├── StepGridView.swift         # Step grid components
├── MenuView.swift             # Menu and navigation components
└── MixingCenterView.swift     # Mixing interface components
```

## Dependencies

### External Dependencies
- **SwiftUI**: UI framework
- **AudioManager**: Audio playback and control
- **SequencerState**: Sequencer state management
- **Room**: Room data model

### Internal Dependencies
- Components can depend on other components through composition
- Avoid circular dependencies
- Use protocols for loose coupling when needed

## Testing

Each component includes SwiftUI preview providers for visual testing. For unit testing:

1. Create test files in the test target
2. Mock dependencies using protocols
3. Test component behavior in isolation
4. Test component integration

## Performance Considerations

- Use `@ObservedObject` only when necessary
- Prefer `@State` for local component state
- Use `LazyVStack` and `LazyHStack` for large lists
- Minimize view updates through proper state management
- Use `@StateObject` for component-owned objects

## Future Enhancements

- Add component composition examples
- Create component testing utilities
- Add accessibility support documentation
- Implement component theming system
- Add animation guidelines
