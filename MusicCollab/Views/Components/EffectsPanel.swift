import SwiftUI

struct EffectsPanel: View {
    @ObservedObject var track: Track
    @ObservedObject var effectsManager = EffectsManager.shared
    @State private var selectedEffectType: EffectType?
    @State private var showingAddEffect = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Effects List
                effectsListView
                
                // Add Effect Button
                addEffectButton
            }
            .navigationTitle("Effects - \(track.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddEffect) {
            AddEffectView(track: track, effectsManager: effectsManager)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Track Effects")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(track.enabledEffects.count) active")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Effects List View
    
    private var effectsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(track.effects.values.sorted(by: { $0.name < $1.name }), id: \.id) { effect in
                    EffectRowView(
                        effect: effect,
                        onToggle: { toggleEffect(effect) },
                        onRemove: { removeEffect(effect) }
                    )
                }
                
                if track.effects.isEmpty {
                    emptyStateView
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Effects Added")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Add effects to enhance your track's sound")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Add Effect Button
    
    private var addEffectButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: {
                showingAddEffect = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Add Effect")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    // MARK: - Actions
    
    private func toggleEffect(_ effect: AudioEffect) {
        if effect.isEnabled {
            effectsManager.disableEffect(effect)
        } else {
            effectsManager.enableEffect(effect)
        }
    }
    
    private func removeEffect(_ effect: AudioEffect) {
        track.removeEffect(withId: effect.id)
        // Detach from audio engine
        if let audioUnit = effect.audioUnit {
            effectsManager.audioEngine?.detach(audioUnit)
        }
    }
}

// MARK: - Effect Row View

struct EffectRowView: View {
    let effect: AudioEffect
    let onToggle: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Effect Icon
            effectIcon
            
            // Effect Info
            VStack(alignment: .leading, spacing: 4) {
                Text(effect.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                effectDescription
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 8) {
                // Toggle Button
                Button(action: onToggle) {
                    Image(systemName: effect.isEnabled ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(effect.isEnabled ? .green : .secondary)
                }
                
                // Remove Button
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var effectIcon: some View {
        Image(systemName: iconName)
            .font(.title2)
            .foregroundColor(.blue)
            .frame(width: 32, height: 32)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
    }
    
    private var iconName: String {
        if let reverbEffect = effect as? ReverbEffect {
            return "waveform"
        } else if let filterEffect = effect as? FilterEffect {
            return "slider.horizontal.3"
        } else if let delayEffect = effect as? DelayEffect {
            return "clock.arrow.circlepath"
        }
        return "effect"
    }
    
    @ViewBuilder
    private var effectDescription: some View {
        if let reverbEffect = effect as? ReverbEffect {
            Text("Dry/Wet: \(Int(reverbEffect.parameters.dryWetMix * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        } else if let filterEffect = effect as? FilterEffect {
            Text("Freq: \(filterEffect.frequencyDisplayString(filterEffect.parameters.frequency))")
                .font(.caption)
                .foregroundColor(.secondary)
        } else if let delayEffect = effect as? DelayEffect {
            Text("Delay: \(Int(delayEffect.parameters.delayTime * 1000))ms")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            Text("Audio Effect")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Add Effect View

struct AddEffectView: View {
    @ObservedObject var track: Track
    @ObservedObject var effectsManager: EffectsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Add Effect to \(track.name)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Divider()
                }
                .padding()
                
                // Effect Types List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(EffectType.allCases, id: \.self) { effectType in
                            EffectTypeRowView(
                                effectType: effectType,
                                onTap: { addEffect(effectType) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Add Effect")
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
    
    private func addEffect(_ effectType: EffectType) {
        _ = effectsManager.addEffectToTrack(track, effectType: effectType)
        dismiss()
    }
}

// MARK: - Effect Type Row View

struct EffectTypeRowView: View {
    let effectType: EffectType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: effectType.iconName)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(effectType.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(effectTypeDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var effectTypeDescription: String {
        switch effectType {
        case .reverb:
            return "Add spatial depth and ambience"
        case .filter:
            return "Control frequency content"
        case .delay:
            return "Add echo and spatial effects"
        }
    }
}

// MARK: - Preview

#Preview {
    EffectsPanel(track: Track(name: "Kick", sampleName: "kick"))
}
