import SwiftUI

/**
 # StepGridView
 
 A modular component for displaying and interacting with the sequencer step grid.
 
 ## Features
 - Responsive layout (1x16 landscape, 2x8 portrait)
 - Visual step indicators with active/inactive states
 - Color-coded steps matching selected sound
 - Real-time step toggling
 - Current playing step highlighting
 - Full-width responsive design
 
 ## Usage
 ```swift
 StepGridView(
     sequencerState: sequencerState,
     selectedSound: selectedSound,
     isLandscape: geometry.size.width > geometry.size.height
 )
 ```
 
 ## Parameters
 - `sequencerState`: ObservableObject containing sequencer state and pattern data
 - `selectedSound`: Currently selected sound for step placement
 - `isLandscape`: Boolean indicating landscape orientation for layout
 
 ## Layout Modes
 - **Landscape**: Single row of 16 steps (1x16)
 - **Portrait**: Two rows of 8 steps each (2x8)
 
 ## Step States
 - **Inactive**: Empty circle outline
 - **Active**: Filled circle with sound color
 - **Current Playing**: Pulsing animation
 */
struct StepGridView: View {
    @ObservedObject var sequencerState: SequencerState
    let selectedSound: String
    let isLandscape: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            if isLandscape {
                // Landscape: 1x16 steps
                HStack(spacing: 2) {
                    ForEach(0..<16, id: \.self) { stepIndex in
                        StepButton(
                            stepIndex: stepIndex,
                            sequencerState: sequencerState,
                            selectedSound: selectedSound
                        )
                    }
                }
            } else {
                // Portrait: 2x8 steps
                VStack(spacing: 2) {
                    // First row (steps 0-7)
                    HStack(spacing: 2) {
                        ForEach(0..<8, id: \.self) { stepIndex in
                            StepButton(
                                stepIndex: stepIndex,
                                sequencerState: sequencerState,
                                selectedSound: selectedSound
                            )
                        }
                    }
                    
                    // Second row (steps 8-15)
                    HStack(spacing: 2) {
                        ForEach(8..<16, id: \.self) { stepIndex in
                            StepButton(
                                stepIndex: stepIndex,
                                sequencerState: sequencerState,
                                selectedSound: selectedSound
                            )
                        }
                    }
                }
            }
        }
    }
}

/**
 # StepButton
 
 Individual step button component within the step grid.
 
 ## Features
 - Toggle step active/inactive state
 - Visual feedback for different states
 - Color matching selected sound
 - Playing step animation
 - Large touch target for easy interaction
 */
struct StepButton: View {
    let stepIndex: Int
    @ObservedObject var sequencerState: SequencerState
    let selectedSound: String
    
    private var isActive: Bool {
        let track = sequencerState.currentPattern.tracks.first { $0.sampleName == selectedSound }
        guard let track = track, stepIndex >= 0 && stepIndex < track.steps.count else { return false }
        return track.steps[stepIndex].isActive
    }
    
    private var isCurrentStep: Bool {
        sequencerState.currentStep == stepIndex
    }
    
    private var buttonColor: Color {
        switch selectedSound {
        case "kick": return .red
        case "snare": return .blue
        case "hihat": return .green
        case "hihat2": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        Button {
            toggleStep()
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? buttonColor : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? buttonColor : Color.primary, lineWidth: 2)
                )
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .scaleEffect(isCurrentStep ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isCurrentStep)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleStep() {
        guard let trackIndex = sequencerState.currentPattern.tracks.firstIndex(where: { $0.sampleName == selectedSound }) else { return }
        sequencerState.currentPattern.tracks[trackIndex].toggleStep(at: stepIndex)
    }
}

// MARK: - Preview
struct StepGridView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            StepGridView(
                sequencerState: SequencerState(pattern: Pattern.mockPattern),
                selectedSound: "kick",
                isLandscape: true
            )
            .previewDisplayName("Landscape (1x16)")
            
            StepGridView(
                sequencerState: SequencerState(pattern: Pattern.mockPattern),
                selectedSound: "snare",
                isLandscape: false
            )
            .previewDisplayName("Portrait (2x8)")
        }
        .padding()
    }
}
