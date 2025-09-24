import SwiftUI

/**
 # SoundSelectionView
 
 A modular component for selecting drum sounds to add to the sequencer grid.
 
## Features
- Compact sound selection buttons
- Visual indication of selected sound
- Color-coded sound categories
- Full-width responsive design
 
 ## Usage
 ```swift
 SoundSelectionView(selectedSound: $selectedSound)
 ```
 
 ## Parameters
 - `selectedSound`: Binding to the currently selected sound name
 
 ## Available Sounds
 - **Kick**: Bass drum sound (Red)
 - **Snare**: Snare drum sound (Blue) 
 - **Hi-Hat**: Closed hi-hat sound (Green)
 - **Hi-Hat 2**: Open hi-hat sound (Purple)
 
## Interaction
- Tap a sound button to select it for grid placement
- Selected sound is highlighted with a border
 */
struct SoundSelectionView: View {
    @Binding var selectedSound: String
    @ObservedObject var sequencerState: SequencerState
    @State private var showingEffectsPanel = false
    @State private var selectedTrackForEffects: Track?
    
    private let sounds = [
        ("kick", "Kick", Color.red),
        ("snare", "Snare", Color.blue),
        ("hihat", "Hi-Hat", Color.green),
        ("hihat2", "Hi-Hat2", Color.purple)
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(sounds, id: \.0) { sound in
                VStack(spacing: 4) {
                    Image(systemName: soundIcon(for: sound.0))
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text(sound.1)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(sound.2)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedSound == sound.0 ? Color.white : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    selectedSound = sound.0
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    // Long press to open effects panel
                    openEffectsPanel(for: sound.0)
                }
            }
        }
        .sheet(isPresented: $showingEffectsPanel) {
            if let track = selectedTrackForEffects {
                TrackEffectsPanel(track: track)
            }
        }
    }
    
    private func soundIcon(for sound: String) -> String {
        switch sound {
        case "kick": return "circle.fill"
        case "snare": return "oval.fill"
        case "hihat": return "circle.fill"
        case "hihat2": return "circle.fill"
        default: return "circle.fill"
        }
    }
    
    private func openEffectsPanel(for soundName: String) {
        // Find the track with the matching sample name in the sequencer state
        if let track = sequencerState.currentPattern.tracks.first(where: { $0.sampleName == soundName }) {
            selectedTrackForEffects = track
            showingEffectsPanel = true
        } else {
            // If no track exists, create a new one and add it to the pattern
            let newTrack = Track(name: soundName.capitalized, sampleName: soundName)
            sequencerState.currentPattern.tracks.append(newTrack)
            selectedTrackForEffects = newTrack
            showingEffectsPanel = true
        }
    }
}

// MARK: - Preview
struct SoundSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SoundSelectionView(selectedSound: .constant("kick"), sequencerState: SequencerState(pattern: Pattern.mockPattern))
                .previewDisplayName("Kick Selected")
            
            SoundSelectionView(selectedSound: .constant("snare"), sequencerState: SequencerState(pattern: Pattern.mockPattern))
                .previewDisplayName("Snare Selected")
        }
        .padding()
    }
}
