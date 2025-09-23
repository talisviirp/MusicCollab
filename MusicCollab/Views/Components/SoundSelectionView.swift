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
    
    private let sounds = [
        ("kick", "Kick", Color.red),
        ("snare", "Snare", Color.blue),
        ("hihat", "Hi-Hat", Color.green),
        ("hihat2", "Hi-Hat2", Color.purple)
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(sounds, id: \.0) { sound in
                Button {
                    selectedSound = sound.0
                } label: {
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
                }
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
}

// MARK: - Preview
struct SoundSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SoundSelectionView(selectedSound: .constant("kick"))
                .previewDisplayName("Kick Selected")
            
            SoundSelectionView(selectedSound: .constant("snare"))
                .previewDisplayName("Snare Selected")
        }
        .padding()
    }
}
