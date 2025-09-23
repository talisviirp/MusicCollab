import SwiftUI

/**
 # TempoControlView
 
 A modular component for controlling the sequencer's tempo (BPM).
 
 ## Features
 - Displays current BPM value
 - Opens a modal with a slider for tempo adjustment
 - Live tempo updates without audio interruption
 - Compact button design for toolbar integration
 
 ## Usage
 ```swift
 TempoButtonView(tempo: $sequencerState.currentPattern.tempo, showingTempoControl: $showingTempoControl)
 ```
 
 ## Parameters
 - `tempo`: Binding to the current tempo value
 - `showingTempoControl`: Binding to control modal presentation
 */
struct TempoButtonView: View {
    @Binding var tempo: Double
    @Binding var showingTempoControl: Bool
    
    var body: some View {
        Button {
            showingTempoControl = true
        } label: {
            Text("\(Int(tempo))")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(width: 60, height: 40)
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
        .sheet(isPresented: $showingTempoControl) {
            TempoControlView(tempo: $tempo)
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
        }
    }
}

/**
 # TempoControlView
 
 Modal view for adjusting the sequencer tempo with a slider.
 
 ## Features
 - Large, easy-to-use tempo slider
 - Live tempo updates
 - BPM display
 - Compact modal presentation (25% height)
 
 ## Usage
 Used internally by TempoButtonView when the tempo button is tapped.
 */
struct TempoControlView: View {
    @Binding var tempo: Double
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("\(Int(tempo)) BPM")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Slider(value: $tempo, in: 60...200, step: 1)
                    .accentColor(.blue)
                    .onChange(of: tempo) { audioManager.updateTempo(tempo) }
                
                HStack {
                    Text("60")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("200")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Tempo")
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

// MARK: - Preview
struct TempoControlView_Previews: PreviewProvider {
    static var previews: some View {
        TempoButtonView(tempo: .constant(120), showingTempoControl: .constant(false))
            .previewDisplayName("Tempo Button")
        
        TempoControlView(tempo: .constant(120))
            .previewDisplayName("Tempo Control Modal")
    }
}
