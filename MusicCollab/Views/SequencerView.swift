import SwiftUI

/**
 # SequencerView
 
 The main sequencer interface that orchestrates all modular components.
 
 ## Features
 - Modular component architecture
 - Responsive layout for different orientations
 - Real-time audio playback control
 - Integrated mixing center
 - Room management
 - Tempo control
 - Sound selection and step sequencing
 
 ## Architecture
 This view acts as a coordinator that brings together multiple specialized components:
 - TempoControlView: BPM control
 - TransportControlsView: Play/pause/stop controls
 - SoundSelectionView: Drum sound selection
 - StepGridView: Step sequencing interface
 - MenuView: Room information and actions
 - MixingCenterView: Audio mixing interface
 
 ## Usage
 ```swift
 SequencerView(room: selectedRoom)
 ```
 
 ## Parameters
 - `room`: Room object containing room information
 */
struct SequencerView: View {
    let room: Room
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var sequencerState = SequencerState(pattern: Pattern.mockPattern)
    @State private var selectedSound: String = "kick"
    @State private var showingMixingCenter = false
    @State private var showingTempoControl = false
    @State private var showingMenu = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 16) {
                    Spacer()
                    
                    // Bottom section with controls and sequencer
                    VStack(spacing: 16) {
                        // Tempo, Transport, and Sound Selection in one row
                        HStack(spacing: 12) {
                            // Tempo Control
                            TempoButtonView(tempo: $sequencerState.currentPattern.tempo, showingTempoControl: $showingTempoControl)
                            
                            // Transport Controls
                            TransportControlsView(
                                isPlaying: $sequencerState.isPlaying,
                                audioManager: audioManager
                            )
                        }
                        
                        // Sound Selection - Full width
                        SoundSelectionView(selectedSound: $selectedSound)
                        
                        // Step Grid - Responsive to orientation - positioned at bottom
                        if geometry.size.width > geometry.size.height {
                            // Landscape: 1x16 steps
                            StepGridView(sequencerState: sequencerState, selectedSound: selectedSound, isLandscape: true)
                        } else {
                            // Portrait: 2x8 steps
                            StepGridView(sequencerState: sequencerState, selectedSound: selectedSound, isLandscape: false)
                        }
                    }
                }
                .padding()
                .navigationTitle("Sequencer")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingMenu = true
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingMixingCenter = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .sheet(isPresented: $showingMixingCenter) {
                    MixingCenterView(sequencerState: sequencerState)
                }
                .sheet(isPresented: $showingMenu) {
                    MenuView(room: room) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            audioManager.setSequencerState(sequencerState)
        }
    }
}

// MARK: - Preview
struct SequencerView_Previews: PreviewProvider {
    static var previews: some View {
        SequencerView(room: Room(name: "Preview Room", participantCount: 3))
            .previewDisplayName("Sequencer")
    }
}
