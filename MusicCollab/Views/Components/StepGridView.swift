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
                        StepButtonContent(
                            stepIndex: stepIndex,
                            track: sequencerState.currentPattern.tracks.first { $0.sampleName == selectedSound } ?? Track(name: "Default", sampleName: selectedSound),
                            selectedSound: selectedSound,
                            isCurrentStep: sequencerState.currentStep == stepIndex
                        )
                        
                        // Add cap after each 4th step except the last step
                        if (stepIndex + 1) % 4 == 0 && stepIndex < 15 {
                            Rectangle()
                                .fill(Color.primary.opacity(0.3))
                                .frame(width: 2, height: 20)
                        }
                    }
                }
            } else {
                // Portrait: 2x8 steps
                VStack(spacing: 2) {
                    // First row (steps 0-7)
                    HStack(spacing: 2) {
                        ForEach(0..<8, id: \.self) { stepIndex in
                            StepButtonContent(
                                stepIndex: stepIndex,
                                track: sequencerState.currentPattern.tracks.first { $0.sampleName == selectedSound } ?? Track(name: "Default", sampleName: selectedSound),
                                selectedSound: selectedSound,
                                isCurrentStep: sequencerState.currentStep == stepIndex
                            )
                            
                            // Add cap after each 4th step except the last step in row
                            if (stepIndex + 1) % 4 == 0 && stepIndex < 7 {
                                Rectangle()
                                    .fill(Color.primary.opacity(0.3))
                                    .frame(width: 2, height: 20)
                            }
                        }
                    }
                    
                    // Second row (steps 8-15)
                    HStack(spacing: 2) {
                        ForEach(8..<16, id: \.self) { stepIndex in
                            StepButtonContent(
                                stepIndex: stepIndex,
                                track: sequencerState.currentPattern.tracks.first { $0.sampleName == selectedSound } ?? Track(name: "Default", sampleName: selectedSound),
                                selectedSound: selectedSound,
                                isCurrentStep: sequencerState.currentStep == stepIndex
                            )
                            
                            // Add cap after each 4th step except the last step in row
                            if (stepIndex + 1) % 4 == 0 && stepIndex < 15 {
                                Rectangle()
                                    .fill(Color.primary.opacity(0.3))
                                    .frame(width: 2, height: 20)
                            }
                        }
                    }
                }
            }
        }
    }
}


struct StepButtonContent: View {
    let stepIndex: Int
    @ObservedObject var track: Track
    let selectedSound: String
    let isCurrentStep: Bool
    
    private var isActive: Bool {
        guard stepIndex >= 0 && stepIndex < track.steps.count else {
            return false
        }
        return track.steps[stepIndex].isActive
    }
    
    private var isFirstStepOfBeat: Bool {
        stepIndex % 4 == 0
    }
    
    private var buttonColor: Color {
        switch selectedSound {
        case "kick": return .red
        case "snare": return .blue
        case "hiHat": return .green
        case "hiHat2": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: {
            print("Tapping step \(stepIndex) for sound \(selectedSound)")
            let wasActive = track.steps[stepIndex].isActive
            track.toggleStep(at: stepIndex)
            let isNowActive = track.steps[stepIndex].isActive
            
            if isNowActive && !wasActive {
                print("Sound \(selectedSound) is added to step \(stepIndex)")
            } else if !isNowActive && wasActive {
                print("Sound \(selectedSound) is removed from step \(stepIndex)")
            }
        }) {
            ZStack {
                // Background rectangle
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? buttonColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary, lineWidth: isFirstStepOfBeat ? 4 : 2)
                    )
                
                // Debug: Show step index
                Text("\(stepIndex)")
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .scaleEffect(isCurrentStep ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.01), value: isCurrentStep)
    }
}

// MARK: - Preview
//struct StepGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 20) {
//            StepGridView(
//                sequencerState: SequencerState(pattern: Pattern.mockPattern),
//                selectedSound: "kick",
//                isLandscape: true
//            )
//            .previewDisplayName("Landscape (1x16)")
//            
//            StepGridView(
//                sequencerState: SequencerState(pattern: Pattern.mockPattern),
//                selectedSound: "snare",
//                isLandscape: false
//            )
//            .previewDisplayName("Portrait (2x8)")
//        }
//        .padding()
//    }
//}
