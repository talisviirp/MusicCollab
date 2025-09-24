import SwiftUI
import AVFoundation

// MARK: - Reverb Control View

struct ReverbControlView: View {
    @ObservedObject var reverbEffect: ReverbEffect
    @State private var showingPresetPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerView
            
            // Dry/Wet Mix
            dryWetMixControl
            
            // Preset Selection
            presetControl
            
            // Bypass Toggle
            bypassControl
        }
        .padding()
        .sheet(isPresented: $showingPresetPicker) {
            ReverbPresetPickerView(
                selectedPreset: $reverbEffect.parameters.preset,
                onPresetSelected: { preset in
                    reverbEffect.setPreset(preset)
                }
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "waveform")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("Reverb")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Add spatial depth and ambience")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var dryWetMixControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Dry/Wet Mix")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(reverbEffect.parameters.dryWetMix * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(
                value: Binding(
                    get: { reverbEffect.parameters.dryWetMix },
                    set: { reverbEffect.setDryWetMix($0) }
                ),
                in: 0...1,
                step: 0.01
            )
            .accentColor(.blue)
        }
    }
    
    private var presetControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preset")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Button(action: {
                showingPresetPicker = true
            }) {
                HStack {
                    Text(reverbEffect.parameters.preset.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var bypassControl: some View {
        HStack {
            Text("Bypass")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { reverbEffect.parameters.bypass },
                set: { reverbEffect.setBypass($0) }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .red))
        }
    }
}

// MARK: - Filter Control View

struct FilterControlView: View {
    @ObservedObject var filterEffect: FilterEffect
    @State private var showingFilterTypePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerView
            
            // Filter Type
            filterTypeControl
            
            // Frequency Control
            frequencyControl
            
            // Resonance Control
            resonanceControl
            
            // Bypass Toggle
            bypassControl
        }
        .padding()
        .sheet(isPresented: $showingFilterTypePicker) {
            FilterTypePickerView(
                selectedType: $filterEffect.parameters.filterType,
                onTypeSelected: { type in
                    filterEffect.setFilterType(type)
                }
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "slider.horizontal.3")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("Filter")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Control frequency content")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var filterTypeControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter Type")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Button(action: {
                showingFilterTypePicker = true
            }) {
                HStack {
                    Text(filterEffect.parameters.filterType.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var frequencyControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Frequency")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(filterEffect.frequencyDisplayString(filterEffect.parameters.frequency))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(
                value: Binding(
                    get: { filterEffect.frequencyToPercentage(filterEffect.parameters.frequency) },
                    set: { percentage in
                        let frequency = filterEffect.percentageToFrequency(percentage)
                        filterEffect.setFrequency(frequency)
                    }
                ),
                in: 0...1,
                step: 0.001
            )
            .accentColor(.blue)
        }
    }
    
    private var resonanceControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Resonance")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(format: "%.1f", filterEffect.parameters.resonance))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(
                value: Binding(
                    get: { filterEffect.parameters.resonance },
                    set: { filterEffect.setResonance($0) }
                ),
                in: 0.1...20.0,
                step: 0.1
            )
            .accentColor(.blue)
        }
    }
    
    private var bypassControl: some View {
        HStack {
            Text("Bypass")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { filterEffect.parameters.bypass },
                set: { filterEffect.setBypass($0) }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .red))
        }
    }
}

// MARK: - Reverb Preset Picker

struct ReverbPresetPickerView: View {
    @Binding var selectedPreset: AVAudioUnitReverbPreset
    let onPresetSelected: (AVAudioUnitReverbPreset) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(AVAudioUnitReverbPreset.allCases, id: \.self) { preset in
                Button(action: {
                    selectedPreset = preset
                    onPresetSelected(preset)
                    dismiss()
                }) {
                    HStack {
                        Text(preset.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedPreset == preset {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Reverb Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Filter Type Picker

struct FilterTypePickerView: View {
    @Binding var selectedType: FilterType
    let onTypeSelected: (FilterType) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(FilterType.allCases, id: \.self) { type in
                Button(action: {
                    selectedType = type
                    onTypeSelected(type)
                    dismiss()
                }) {
                    HStack {
                        Text(type.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedType == type {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Filter Types")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Delay Control View

struct DelayControlView: View {
    @ObservedObject var delayEffect: DelayEffect
    @State private var showingPresetPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerView
            
            // Delay Time
            delayTimeControl
            
            // Feedback
            feedbackControl
            
            // Wet/Dry Mix
            wetDryMixControl
            
            // Preset Selection
            presetControl
            
            // Bypass Toggle
            bypassControl
        }
        .padding()
        .sheet(isPresented: $showingPresetPicker) {
            DelayPresetPickerView(
                selectedPreset: .constant(.medium),
                onPresetSelected: { preset in
                    delayEffect.applyPreset(preset)
                }
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title2)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading) {
                Text("Delay")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Add echo and spatial effects")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var delayTimeControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Delay Time")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(delayEffect.parameters.delayTime * 1000))ms")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: Binding(
                    get: { delayEffect.parameters.delayTime },
                    set: { delayEffect.setDelayTime($0) }
                ),
                in: 0.0...2.0,
                step: 0.025
            )
            .accentColor(.orange)
        }
    }
    
    private var feedbackControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Feedback")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(delayEffect.parameters.feedback))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: Binding(
                    get: { delayEffect.parameters.feedback },
                    set: { delayEffect.setFeedback($0) }
                ),
                in: 0.0...100.0,
                step: 1.0
            )
            .accentColor(.orange)
        }
    }
    
    private var wetDryMixControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Wet/Dry Mix")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(delayEffect.parameters.wetDryMix))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: Binding(
                    get: { delayEffect.parameters.wetDryMix },
                    set: { delayEffect.setWetDryMix($0) }
                ),
                in: 0.0...100.0,
                step: 1.0
            )
            .accentColor(.orange)
        }
    }
    
    private var presetControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Presets")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Button(action: {
                showingPresetPicker = true
            }) {
                HStack {
                    Text("Select Preset")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var bypassControl: some View {
        Toggle("Bypass", isOn: Binding(
            get: { delayEffect.parameters.bypass },
            set: { delayEffect.setBypass($0) }
        ))
        .toggleStyle(SwitchToggleStyle(tint: .orange))
    }
}

// MARK: - Delay Preset Picker View

struct DelayPresetPickerView: View {
    @Binding var selectedPreset: DelayPreset
    let onPresetSelected: (DelayPreset) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(DelayPreset.allCases, id: \.self) { preset in
                Button(action: {
                    selectedPreset = preset
                    onPresetSelected(preset)
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preset.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(preset.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Delay Presets")
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

#Preview {
    VStack {
        ReverbControlView(reverbEffect: ReverbEffect())
        Divider()
        FilterControlView(filterEffect: FilterEffect())
        Divider()
        DelayControlView(delayEffect: DelayEffect())
    }
}
