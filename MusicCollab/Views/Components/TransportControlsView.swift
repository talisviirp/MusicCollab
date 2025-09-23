import SwiftUI

/**
 # TransportControlsView
 
 A modular component for controlling sequencer playback (play, pause, stop).
 
 ## Features
 - Play/Pause toggle button with visual state indication
 - Stop button to halt and reset playback
 - Real-time state synchronization with AudioManager
 - Compact design for toolbar integration
 
 ## Usage
 ```swift
 TransportControlsView(
     isPlaying: $sequencerState.isPlaying,
     audioManager: audioManager
 )
 ```
 
 ## Parameters
 - `isPlaying`: Binding to the current playback state
 - `audioManager`: Reference to the shared AudioManager instance
 
 ## Button States
 - **Play Button**: Shows play icon when stopped, pause icon when playing
 - **Stop Button**: Always visible, stops playback and resets sequencer
 */
struct TransportControlsView: View {
    @Binding var isPlaying: Bool
    let audioManager: AudioManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Play/Pause Button
            Button {
                if isPlaying {
                    audioManager.pausePlayback()
                } else {
                    audioManager.startPlayback()
                }
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 40)
                    .background(isPlaying ? Color.orange : Color.green)
                    .cornerRadius(8)
            }
            
            // Stop Button
            Button {
                audioManager.stopPlayback()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 40)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Preview
struct TransportControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TransportControlsView(
                isPlaying: .constant(false),
                audioManager: AudioManager.shared
            )
            .previewDisplayName("Stopped State")
            
            TransportControlsView(
                isPlaying: .constant(true),
                audioManager: AudioManager.shared
            )
            .previewDisplayName("Playing State")
        }
        .padding()
    }
}
