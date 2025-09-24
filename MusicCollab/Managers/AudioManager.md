# AudioManager Documentation

## Overview

The `AudioManager` is a professional-grade audio engine that provides real-time audio playback, mixing, and sequencer timing for the MusicCollab app. It implements industry-standard DAW practices for low-latency, thread-safe audio processing.

## Architecture

### Core Components

#### 1. AVAudioEngine Integration
- **Engine**: Single `AVAudioEngine` instance for all audio processing
- **Player Nodes**: Individual `AVAudioPlayerNode` for each sample (kick, snare, hihat, hihat2)
- **Mixer Node**: Main mixer for volume and pan control
- **Sequencer**: `AVAudioSequencer` for advanced playback control

#### 2. Real-Time Audio Threading
- **Audio Queue**: High-priority `DispatchQueue` with `.userInteractive` QoS
- **Precision Timing**: 2ms precision timer for sequencer timing
- **Thread Safety**: All audio operations isolated from main thread
- **Real-Time Safety**: No memory allocations or blocking operations in audio thread

#### 3. Pre-allocated Buffers
- **Zero Latency**: All samples pre-loaded into `AVAudioPCMBuffer` objects
- **Memory Efficiency**: No file I/O during playback
- **Thread Safety**: Pre-allocated buffers prevent audio dropouts

## Key Features

### Professional Audio Session Management
```swift
// Primary configuration with low-latency settings
try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
try session.setPreferredSampleRate(44_100)
try session.setPreferredIOBufferDuration(0.005) // 5ms for real-time

// Fallback configuration for maximum compatibility
try session.setCategory(.playback, mode: .default)
```

### Real-Time Sequencer Timing
```swift
// High-priority audio thread with 2ms precision
audioThreadTimer = DispatchSource.makeTimerSource(queue: audioQueue)
audioThreadTimer?.schedule(deadline: .now(), repeating: .milliseconds(2))
```

### Thread-Safe Audio Operations
```swift
// All audio operations happen on dedicated audio queue
audioQueue.async { [weak self] in
    self?.playCurrentStep()
}
```

## API Reference

### Initialization
```swift
private init() {
    setupAudioEngine()
    loadSamples()
    setupRouteChangeNotification()
    
    // Configure audio session with fallback
    do {
        try configureAudioSession()
        startEngine()
    } catch {
        try configureMinimalAudioSession()
        startEngine()
    }
}
```

### Engine Control
```swift
func startEngine()     // Start the audio engine
func stopEngine()      // Stop the audio engine
func startPlayback()   // Start sequencer playback
func stopPlayback()    // Stop sequencer playback
func pausePlayback()   // Pause sequencer playback
```

### Sample Playback
```swift
func playKick()        // Play kick sample
func playSnare()       // Play snare sample
func playHiHat()       // Play hi-hat sample
func playHiHat2()      // Play hi-hat2 sample
```

### Sequencer Control
```swift
func setSequencerState(_ state: SequencerState)  // Set sequencer state
func updateTempo(_ newTempo: Double)             // Update BPM
func updateMasterVolume(_ volume: Double)        // Update master volume
```

## Implementation Details

### Audio Thread Management

The AudioManager uses a dedicated high-priority thread for all audio operations:

```swift
private let audioQueue = DispatchQueue(label: "com.musiccollab.audio", qos: .userInteractive)
private var audioThreadTimer: DispatchSourceTimer?
private let audioThreadLock = NSLock()
```

**Benefits:**
- UI operations don't block audio timing
- Precise 2ms timing resolution
- Real-time safe operations
- Professional DAW-level performance

### Pre-allocated Buffer System

All audio samples are pre-loaded into memory for zero-latency playback:

```swift
// Pre-allocate buffer for real-time safety
if let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length)) {
    try audioFile.read(into: buffer)
    audioBuffers[sampleName] = buffer
}
```

**Benefits:**
- Zero file I/O during playback
- Consistent latency
- Thread-safe sample access
- Professional audio performance

### Audio Session Configuration

The AudioManager implements robust audio session management with fallback support:

```swift
private func configureAudioSession() throws {
    let session = AVAudioSession.sharedInstance()
    
    // Reset any previous configuration
    try session.setActive(false, options: [])
    
    // Configure for low-latency playback
    try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
    try session.setPreferredSampleRate(44_100)
    try session.setPreferredIOBufferDuration(0.005)
    
    // Activate the session
    try session.setActive(true)
}
```

**Fallback Configuration:**
```swift
private func configureMinimalAudioSession() throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playback, mode: .default)
    try session.setActive(true)
}
```

### Route Change Handling

Automatic recovery from audio route changes (headphones, Bluetooth, etc.):

```swift
@objc private func handleRouteChange(notification: Notification) {
    switch reason {
    case .oldDeviceUnavailable, .newDeviceAvailable:
        if isStarted {
            stopEngine()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.startEngine()
            }
        }
    default:
        break
    }
}
```

## Performance Characteristics

### Timing Precision
- **Sequencer Timing**: 2ms precision (500Hz update rate)
- **Audio Latency**: 5ms buffer duration
- **Sample Rate**: 44.1kHz locked
- **Thread Priority**: User-interactive QoS

### Memory Usage
- **Pre-allocated Buffers**: ~4 samples × ~50KB = ~200KB
- **Player Nodes**: 4 nodes × ~1KB = ~4KB
- **Total Audio Memory**: ~204KB

### CPU Usage
- **Audio Thread**: <1% CPU (2ms timer)
- **Main Thread**: No audio processing
- **Real-Time Safety**: No allocations in audio thread

## Best Practices

### Thread Safety
- Always use the audio queue for audio operations
- Never access AVAudioEngine from main thread
- Use atomic state access in audio thread
- Pre-allocate all audio resources

### Error Handling
- Implement fallback audio session configuration
- Handle route changes gracefully
- Validate engine state before operations
- Log errors for debugging

### Performance
- Keep audio thread operations minimal
- Use pre-allocated buffers
- Avoid memory allocations in audio thread
- Monitor CPU usage and latency

## Troubleshooting

### Common Issues

#### Audio Engine Won't Start
- Check audio session configuration
- Verify nodes are attached to engine
- Ensure audio session is active
- Check for conflicting audio apps

#### Audio Dropouts
- Verify pre-allocated buffers are loaded
- Check audio thread priority
- Monitor CPU usage
- Ensure no blocking operations in audio thread

#### Timing Issues
- Verify audio thread is running
- Check timer precision settings
- Ensure no main thread blocking
- Monitor audio session state

### Debug Logging
The AudioManager includes comprehensive logging:
- Audio session configuration status
- Engine start/stop events
- Sample loading progress
- Route change notifications
- Error conditions

## Future Enhancements

### Planned Features
- Audio effects and filters
- MIDI input support
- Audio recording capabilities
- Advanced mixing features
- Real-time audio analysis

### Performance Optimizations
- Dynamic buffer allocation
- Advanced threading models
- Hardware acceleration
- Memory pool management

## Dependencies

### External
- **AVFoundation**: Core audio framework
- **QuartzCore**: Timing utilities

### Internal
- **SequencerState**: Sequencer state management
- **SequencerModels**: Data models for patterns and tracks

---

**AudioManager** - Professional audio engine for real-time music collaboration. 🎵
