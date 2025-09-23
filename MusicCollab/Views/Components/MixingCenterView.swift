import SwiftUI

/**
 # MixingCenterView
 
 A modular component for the mixing center containing track mixers and master volume control.
 
 ## Features
 - Responsive layout (horizontal landscape, vertical portrait)
 - Individual track mixers with volume, pan, solo, and mute controls
 - Master volume control with transport controls
 - Scrollable track list
 - Real-time audio parameter updates
 - Professional mixing interface
 
 ## Usage
 ```swift
 MixingCenterView(sequencerState: sequencerState)
 ```
 
 ## Parameters
 - `sequencerState`: ObservableObject containing sequencer state and pattern data
 
 ## Layout Modes
 - **Landscape**: Horizontal track mixers with vertical master volume
 - **Portrait**: Vertical track mixers with horizontal master volume
 */
struct MixingCenterView: View {
    @ObservedObject var sequencerState: SequencerState
    @Environment(\.dismiss) private var dismiss
    @State private var masterVolume: Double = 1.0
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 16) {
                    if geometry.size.width > geometry.size.height {
                        // Landscape: Horizontal layout
                        HStack(spacing: 16) {
                            // Track mixers - horizontal
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(sequencerState.currentPattern.tracks, id: \.id) { track in
                                        TrackMixerView(track: track, sequencerState: sequencerState, isHorizontal: true)
                                    }
                                }
                                .padding()
                            }
                            
                            // Master volume - vertical like other tracks with fixed width
                            MasterVolumeView(volume: $masterVolume, audioManager: audioManager, isHorizontal: false, sequencerState: sequencerState)
                                .frame(width: 200)
                        }
                    } else {
                        // Portrait: Vertical layout with master at bottom
                        VStack(spacing: 16) {
                            // Track mixers - vertical
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(sequencerState.currentPattern.tracks, id: \.id) { track in
                                        TrackMixerView(track: track, sequencerState: sequencerState, isHorizontal: false)
                                    }
                                }
                                .padding()
                            }
                            
                            // Master volume - horizontal at bottom
                            MasterVolumeView(volume: $masterVolume, audioManager: audioManager, isHorizontal: true, sequencerState: sequencerState)
                        }
                    }
                }
                .navigationTitle("Mixing")
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
}

/**
 # TrackMixerView
 
 Individual track mixer component for controlling track parameters.
 
 ## Features
 - Volume control with fader
 - Pan control with horizontal slider
 - Solo button (yellow when active)
 - Mute button (red when active)
 - Live parameter updates
 - Responsive layout (horizontal/vertical)
 
 ## Parameters
 - `track`: Track object containing track data
 - `sequencerState`: ObservableObject for state management
 - `isHorizontal`: Boolean for layout orientation
 */
struct TrackMixerView: View {
    let track: Track
    @ObservedObject var sequencerState: SequencerState
    let isHorizontal: Bool
    @State private var volume: Double
    @State private var pan: Double
    @State private var isMuted: Bool
    @State private var isSoloed: Bool
    
    init(track: Track, sequencerState: SequencerState, isHorizontal: Bool = false) {
        self.track = track
        self.sequencerState = sequencerState
        self.isHorizontal = isHorizontal
        self._volume = State(initialValue: track.volume)
        self._pan = State(initialValue: track.pan)
        self._isMuted = State(initialValue: track.isMuted)
        self._isSoloed = State(initialValue: track.isSoloed)
    }
    
    var body: some View {
        if isHorizontal {
            // Horizontal layout for landscape
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(track.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Solo button
                        Button {
                            isSoloed.toggle()
                            updateTrack()
                        } label: {
                            Image(systemName: isSoloed ? "s.square.fill" : "s.square")
                                .font(.title2)
                                .foregroundColor(isSoloed ? .yellow : .accentColor)
                        }
                        
                        // Mute button
                        Button {
                            isMuted.toggle()
                            updateTrack()
                        } label: {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
                                .font(.title2)
                                .foregroundColor(isMuted ? .red : .accentColor)
                        }
                    }
                    
                    // Pan Control (moved above volume) - horizontal fader for landscape
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("-50")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Slider(value: $pan, in: -1...1)
                                .accentColor(.green)
                                .onChange(of: pan) { updateTrack() }
                            
                            Text("+50")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(panText)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Volume Control (vertical slider for landscape)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Volume")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $volume, in: 0...1)
                            .accentColor(.blue)
                            .rotationEffect(.degrees(-90))
                            .frame(height: 120)
                            .onChange(of: volume) { updateTrack() }
                        
                        Text("\(Int(volume * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary, lineWidth: 2)
            )
            .frame(width: 200)
        } else {
            // Vertical layout for portrait
            VStack(spacing: 12) {
                HStack {
                    Text(track.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Solo button
                    Button {
                        isSoloed.toggle()
                        updateTrack()
                    } label: {
                        Image(systemName: isSoloed ? "s.square.fill" : "s.square")
                            .font(.title2)
                            .foregroundColor(isSoloed ? .yellow : .accentColor)
                    }
                    
                    // Mute button
                    Button {
                        isMuted.toggle()
                        updateTrack()
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
                            .font(.title2)
                            .foregroundColor(isMuted ? .red : .accentColor)
                    }
                }
                
                VStack(spacing: 8) {
                    // Volume Control
                    HStack {
                        Text("Volume")
                            .font(.caption)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $volume, in: 0...1)
                            .accentColor(.blue)
                            .onChange(of: volume) { updateTrack() }
                        
                        Text("\(Int(volume * 100))%")
                            .font(.caption)
                            .frame(width: 40, alignment: .trailing)
                    }
                    
                    // Pan Control - horizontal fader like volume
                    HStack {
                        Text("Pan")
                            .font(.caption)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $pan, in: -1...1)
                            .accentColor(.green)
                            .onChange(of: pan) { updateTrack() }
                        
                        Text(panText)
                            .font(.caption)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary, lineWidth: 2)
            )
        }
    }
    
    private var panText: String {
        let panValue = Int(pan * 50) // Convert -1.0 to 1.0 range to -50 to +50
        if panValue == 0 {
            return "C"
        } else if panValue > 0 {
            return "\(panValue)R"
        } else {
            return "\(abs(panValue))L"
        }
    }
    
    private func updateTrack() {
        // Update the track in the pattern
        if let trackIndex = sequencerState.currentPattern.tracks.firstIndex(where: { $0.id == track.id }) {
            sequencerState.currentPattern.tracks[trackIndex].volume = volume
            sequencerState.currentPattern.tracks[trackIndex].pan = pan
            sequencerState.currentPattern.tracks[trackIndex].isMuted = isMuted
            sequencerState.currentPattern.tracks[trackIndex].isSoloed = isSoloed
        }
    }
}

/**
 # MasterVolumeView
 
 Master volume control component with transport controls.
 
 ## Features
 - Master volume slider
 - Play/Pause button
 - Stop button
 - Live volume display
 - Responsive layout
 */
struct MasterVolumeView: View {
    @Binding var volume: Double
    let audioManager: AudioManager
    let isHorizontal: Bool
    @ObservedObject var sequencerState: SequencerState
    
    var body: some View {
        if isHorizontal {
            // Horizontal layout
            HStack(spacing: 16) {
                Text("Master")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(width: 80, alignment: .leading)
                
                // Transport controls
                HStack(spacing: 8) {
                    // Play/Pause button
                    Button {
                        if sequencerState.isPlaying {
                            audioManager.pausePlayback()
                        } else {
                            audioManager.startPlayback()
                        }
                    } label: {
                        Image(systemName: sequencerState.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // Stop button
                    Button {
                        audioManager.stopPlayback()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(spacing: 8) {
                    Text("\(Int(volume * 100))%")
                        .font(.title2.bold())
                        .foregroundColor(.accentColor)
                    
                    Slider(value: $volume, in: 0...1)
                        .accentColor(.orange)
                        .onChange(of: volume) {
                            audioManager.updateMasterVolume(volume)
                        }
                }
                
                HStack {
                    Text("0%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("100%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 80)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary, lineWidth: 2)
            )
        } else {
            // Vertical layout - same structure as track mixers
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Master")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Transport controls
                    HStack(spacing: 8) {
                        // Play/Pause button
                        Button {
                            if sequencerState.isPlaying {
                                audioManager.pausePlayback()
                            } else {
                                audioManager.startPlayback()
                            }
                        } label: {
                            Image(systemName: sequencerState.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        // Stop button
                        Button {
                            audioManager.stopPlayback()
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Volume Control (vertical slider for landscape)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Volume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $volume, in: 0...1)
                        .accentColor(.orange)
                        .rotationEffect(.degrees(-90))
                        .frame(height: 120)
                        .onChange(of: volume) {
                            audioManager.updateMasterVolume(volume)
                        }
                    
                    Text("\(Int(volume * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary, lineWidth: 2)
            )
        }
    }
}

// MARK: - Preview
struct MixingCenterView_Previews: PreviewProvider {
    static var previews: some View {
        MixingCenterView(sequencerState: SequencerState(pattern: Pattern.mockPattern))
            .previewDisplayName("Mixing Center")
    }
}
