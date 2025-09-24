import Foundation
import AVFoundation
import Combine

class EffectsManager: ObservableObject {
    static let shared = EffectsManager()
    
    @Published var trackEffects: [String: TrackEffects] = [:]
    @Published var masterEffects = MasterEffects()
    
    var audioEngine: AVAudioEngine?
    private var masterMixerNode: AVAudioMixerNode?
    private var trackMixerNodes: [String: AVAudioMixerNode] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Setup
    
    func setup(with audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
        
        // Create master mixer node for final mixing
        masterMixerNode = AVAudioMixerNode()
        if let masterMixer = masterMixerNode {
            audioEngine.attach(masterMixer)
            print("Created master mixer node for final mixing")
        }
        
        // Create track mixer nodes for each sample type
        let sampleTypes = ["kick", "snare", "hihat", "hihat2"]
        for sampleType in sampleTypes {
            let trackMixer = AVAudioMixerNode()
            trackMixerNodes[sampleType] = trackMixer
            audioEngine.attach(trackMixer)
            print("Created track mixer for \(sampleType)")
        }
    }
    
    // MARK: - Track Effects
    
    func addEffectToTrack(_ trackId: String, effectType: EffectType) -> AudioEffect? {
        let effect = createEffect(ofType: effectType)
        
        if let trackEffect = trackEffects[trackId] {
            trackEffect.addEffect(effect)
        } else {
            let newTrackEffect = TrackEffects(trackId: trackId)
            newTrackEffect.addEffect(effect)
            trackEffects[trackId] = newTrackEffect
        }
        
        // Attach effect to audio engine
        attachEffectToEngine(effect)
        
        return effect
    }
    
    func addEffectToTrack(_ track: Track, effectType: EffectType) -> AudioEffect? {
        let effect = createEffect(ofType: effectType)
        track.addEffect(effect)
        
        // Attach effect to audio engine
        attachEffectToEngine(effect)
        
        // Set up routing for this specific track
        if let playerNode = AudioManager.shared.playerNodes[track.sampleName] {
            print("EffectsManager: Setting up routing for track \(track.name) with sample \(track.sampleName)")
            setupTrackRouting(for: track, from: playerNode)
        } else {
            print("EffectsManager: No player node found for track \(track.name) with sample \(track.sampleName)")
        }
        
        return effect
    }
    
    func removeEffectFromTrack(_ trackId: String, effectId: String) {
        guard let trackEffect = trackEffects[trackId] else { return }
        
        if let effect = trackEffect.getEffect(withId: effectId) {
            detachEffectFromEngine(effect)
        }
        
        trackEffect.removeEffect(withId: effectId)
        
        // Rebuild complete routing
        setupCompleteRouting()
    }
    
    func removeEffectFromTrack(_ track: Track, effectId: String) {
        if let effect = track.getEffect(withId: effectId) {
            detachEffectFromEngine(effect)
        }
        
        track.removeEffect(withId: effectId)
        
        // Set up routing for this specific track
        if let playerNode = AudioManager.shared.playerNodes[track.sampleName] {
            setupTrackRouting(for: track, from: playerNode)
        }
    }
    
    func getTrackEffect(_ trackId: String, effectId: String) -> AudioEffect? {
        return trackEffects[trackId]?.getEffect(withId: effectId)
    }
    
    func getTrackEffects(_ trackId: String) -> [AudioEffect] {
        return trackEffects[trackId]?.enabledEffects ?? []
    }
    
    // MARK: - Master Effects
    
    func addMasterEffect(_ effectType: EffectType) -> AudioEffect? {
        let effect = createEffect(ofType: effectType)
        masterEffects.addEffect(effect)
        
        // Attach effect to master output
        attachEffectToMaster(effect)
        
        // Rebuild complete routing
        setupCompleteRouting()
        
        return effect
    }
    
    func removeMasterEffect(_ effectId: String) {
        if let effect = masterEffects.getEffect(withId: effectId) {
            detachEffectFromMaster(effect)
        }
        
        masterEffects.removeEffect(withId: effectId)
        
        // Rebuild complete routing
        setupCompleteRouting()
    }
    
    func getMasterEffect(_ effectId: String) -> AudioEffect? {
        return masterEffects.getEffect(withId: effectId)
    }
    
    func getMasterEffects() -> [AudioEffect] {
        return masterEffects.enabledEffects
    }
    
    // MARK: - Effect Creation
    
    private func createEffect(ofType type: EffectType) -> AudioEffect {
        switch type {
        case .reverb:
            return ReverbEffect()
        case .filter:
            return FilterEffect()
        case .delay:
            return DelayEffect()
        }
    }
    
    // MARK: - Engine Integration
    
    private func attachEffectToEngine(_ effect: AudioEffect) {
        guard let audioEngine = audioEngine else {
            print("EffectsManager: No audio engine available")
            return
        }
        
        guard let audioUnit = effect.createAudioUnit() else {
            print("EffectsManager: Failed to create audio unit for effect \(effect.name)")
            return
        }
        
        audioEngine.attach(audioUnit)
        print("EffectsManager: Attached effect \(effect.name) to engine")
        
        // Verify the reverb unit is properly configured
        if let reverbUnit = audioUnit as? AVAudioUnitReverb {
            print("EffectsManager: Reverb unit attached - wetDryMix: \(reverbUnit.wetDryMix), bypass: \(reverbUnit.bypass)")
            print("EffectsManager: Reverb unit input format: \(reverbUnit.inputFormat(forBus: 0))")
            print("EffectsManager: Reverb unit output format: \(reverbUnit.outputFormat(forBus: 0))")
        }
    }
    
    private func detachEffectFromEngine(_ effect: AudioEffect) {
        guard let audioEngine = audioEngine,
              let audioUnit = effect.audioUnit else { return }
        
        audioEngine.detach(audioUnit)
        print("Detached effect \(effect.name) from engine")
    }
    
    private func attachEffectToMaster(_ effect: AudioEffect) {
        guard let audioEngine = audioEngine,
              let audioUnit = effect.createAudioUnit() else { return }
        
        audioEngine.attach(audioUnit)
        print("Attached master effect \(effect.name) to engine")
    }
    
    private func detachEffectFromMaster(_ effect: AudioEffect) {
        guard let audioEngine = audioEngine,
              let audioUnit = effect.audioUnit else { return }
        
        audioEngine.detach(audioUnit)
        print("Detached master effect \(effect.name) from engine")
    }
    
    // MARK: - Audio Routing
    
    func setupCompleteRouting() {
        guard let audioEngine = audioEngine, let masterMixer = masterMixerNode else { return }
        
        // Stop engine before making routing changes
        let wasRunning = audioEngine.isRunning
        if wasRunning {
            audioEngine.stop()
        }
        
        // Ensure all nodes are attached
        if !audioEngine.attachedNodes.contains(audioEngine.outputNode) {
            audioEngine.attach(audioEngine.outputNode)
        }
        if !audioEngine.attachedNodes.contains(masterMixer) {
            audioEngine.attach(masterMixer)
        }
        
        // Set up master effects routing: masterMixer -> masterEffects -> output
        setupMasterEffectsRouting()
        
        // Restart engine if it was running
        if wasRunning {
            do {
                try audioEngine.start()
            } catch {
                print("Failed to restart audio engine: \(error)")
            }
        }
    }
    
    func setupTrackRouting(for track: Track, from playerNode: AVAudioPlayerNode) {
        guard let audioEngine = audioEngine else { return }
        
        // Stop engine before making routing changes
        let wasRunning = audioEngine.isRunning
        if wasRunning {
            audioEngine.stop()
        }
        
        // First, disconnect any existing connections from this player node
        audioEngine.disconnectNodeOutput(playerNode)
        
        // Also disconnect from main mixer if it exists (fallback connection)
        // This handles the case where AudioManager created a fallback connection
        if audioEngine.attachedNodes.contains(audioEngine.mainMixerNode) {
            // Check if this player node is connected to main mixer
            let connections = audioEngine.outputConnectionPoints(for: playerNode, outputBus: 0)
            for connection in connections {
                if connection.node == audioEngine.mainMixerNode {
                    audioEngine.disconnectNodeOutput(playerNode, bus: 0)
                    print("EffectsManager: Disconnected fallback connection from \(track.sampleName) to main mixer")
                    break
                }
            }
        }
        
        // Get the track mixer for this sample type
        guard let trackMixer = trackMixerNodes[track.sampleName] else {
            print("EffectsManager: No track mixer found for sample \(track.sampleName)")
            return
        }
        
        // Get effects for this track in order
        let effects = track.effects.values.sorted(by: { $0.name < $1.name })
        print("EffectsManager: Setting up routing for track \(track.name) with \(effects.count) effects")
        
        if effects.isEmpty {
            // No effects, connect directly to track mixer
            audioEngine.connect(playerNode, to: trackMixer, format: nil)
            print("EffectsManager: Connected \(track.name) directly to track mixer")
        } else {
            // Connect through effects chain
            var currentNode: AVAudioNode = playerNode
            
            for (index, effect) in effects.enumerated() {
                guard let audioUnit = effect.audioUnit else { 
                    print("EffectsManager: No audio unit for effect \(effect.name)")
                    continue 
                }
                
                print("EffectsManager: Processing effect \(effect.name) (\(index + 1)/\(effects.count)) of type \(type(of: audioUnit))")
                
                // Only attach if not already attached
                if !audioEngine.attachedNodes.contains(audioUnit) {
                    audioEngine.attach(audioUnit)
                    print("EffectsManager: Attached effect \(effect.name) to engine")
                }
                
                // Use the current node's output format to maintain compatibility
                let format = currentNode.outputFormat(forBus: 0)
                audioEngine.connect(currentNode, to: audioUnit, format: format)
                print("EffectsManager: Connected \(currentNode) to \(effect.name) with format: \(format)")
                
                // Verify the connection was successful and effect is properly configured
                print("EffectsManager: Audio unit input format: \(audioUnit.inputFormat(forBus: 0))")
                print("EffectsManager: Audio unit output format: \(audioUnit.outputFormat(forBus: 0))")
                
                // Special debugging for reverb units
                if let reverbUnit = audioUnit as? AVAudioUnitReverb,
                   let reverbEffect = effect as? ReverbEffect {
                    print("EffectsManager: Reverb unit - wetDryMix: \(reverbUnit.wetDryMix), bypass: \(reverbUnit.bypass), preset: \(reverbEffect.parameters.preset)")
                }
                
                currentNode = audioUnit
            }
            
            // Connect last effect to track mixer
            audioEngine.connect(currentNode, to: trackMixer, format: nil)
            print("EffectsManager: Connected last effect (\(currentNode)) to track mixer for \(track.name)")
        }
        
        // Connect track mixer to master mixer
        setupTrackMixerToMaster(trackMixer, sampleName: track.sampleName)
        
        // Ensure master routing is set up (master mixer -> output)
        setupMasterEffectsRouting()
        
        // Restart engine if it was running
        if wasRunning {
            do {
                try audioEngine.start()
                print("EffectsManager: Audio engine restarted successfully")
            } catch {
                print("Failed to restart audio engine: \(error)")
            }
        }
    }
    
    func setupMasterRouting() {
        setupCompleteRouting()
    }
    
    private func setupTrackMixerToMaster(_ trackMixer: AVAudioMixerNode, sampleName: String) {
        guard let audioEngine = audioEngine, let masterMixer = masterMixerNode else { return }
        
        // Disconnect any existing connections from this track mixer
        audioEngine.disconnectNodeOutput(trackMixer)
        
        // Connect track mixer to master mixer
        audioEngine.connect(trackMixer, to: masterMixer, format: nil)
        print("EffectsManager: Connected track mixer (\(sampleName)) to master mixer")
    }
    
    private func setupMasterEffectsRouting() {
        guard let audioEngine = audioEngine, let masterMixer = masterMixerNode else { return }
        
        // Ensure output node is attached
        if !audioEngine.attachedNodes.contains(audioEngine.outputNode) {
            audioEngine.attach(audioEngine.outputNode)
        }
        
        // Disconnect any existing connections from master mixer
        audioEngine.disconnectNodeOutput(masterMixer)
        
        // Get master effects in order
        let masterEffects = masterEffects.effects.values.sorted(by: { $0.name < $1.name })
        
        if masterEffects.isEmpty {
            // No master effects: masterMixer -> output
            audioEngine.connect(masterMixer, to: audioEngine.outputNode, format: nil)
            print("Master routing: masterMixer -> output")
        } else {
            // Create master effects chain: masterMixer -> effect1 -> effect2 -> ... -> output
            var currentNode: AVAudioNode = masterMixer
            
            for effect in masterEffects {
                guard let audioUnit = effect.audioUnit else { continue }
                // Only attach if not already attached
                if !audioEngine.attachedNodes.contains(audioUnit) {
                    audioEngine.attach(audioUnit)
                }
                audioEngine.connect(currentNode, to: audioUnit, format: nil)
                currentNode = audioUnit
            }
            
            // Connect last effect to output
            audioEngine.connect(currentNode, to: audioEngine.outputNode, format: nil)
            print("Master routing: masterMixer -> effects -> output")
        }
    }
    
    // MARK: - Track Mixer Controls
    
    func setTrackVolume(_ sampleName: String, volume: Float) {
        guard let trackMixer = trackMixerNodes[sampleName] else { return }
        trackMixer.volume = volume
        print("Track mixer volume set to \(volume) for \(sampleName)")
    }
    
    func setTrackPan(_ sampleName: String, pan: Float) {
        guard let trackMixer = trackMixerNodes[sampleName] else { return }
        trackMixer.pan = pan
        print("Track mixer pan set to \(pan) for \(sampleName)")
    }
    
    func setTrackMute(_ sampleName: String, muted: Bool) {
        guard let trackMixer = trackMixerNodes[sampleName] else { return }
        trackMixer.outputVolume = muted ? 0.0 : 1.0
        print("Track mixer \(muted ? "muted" : "unmuted") for \(sampleName)")
    }
    
    func setTrackSolo(_ sampleName: String, soloed: Bool) {
        // For solo functionality, we need to mute all other tracks
        for (name, trackMixer) in trackMixerNodes {
            if soloed {
                trackMixer.outputVolume = (name == sampleName) ? 1.0 : 0.0
            } else {
                trackMixer.outputVolume = 1.0
            }
        }
        print("Track \(sampleName) \(soloed ? "soloed" : "unsoloed")")
    }
    
    // MARK: - Effect Management
    
    func enableEffect(_ effect: AudioEffect) {
        if let reverbEffect = effect as? ReverbEffect {
            reverbEffect.isEnabled = true
            reverbEffect.setBypass(false)
        } else if let filterEffect = effect as? FilterEffect {
            filterEffect.isEnabled = true
            filterEffect.setBypass(false)
        } else if let delayEffect = effect as? DelayEffect {
            delayEffect.isEnabled = true
            delayEffect.setBypass(false)
        }
    }
    
    func disableEffect(_ effect: AudioEffect) {
        if let reverbEffect = effect as? ReverbEffect {
            reverbEffect.isEnabled = false
            reverbEffect.setBypass(true)
        } else if let filterEffect = effect as? FilterEffect {
            filterEffect.isEnabled = false
            filterEffect.setBypass(true)
        } else if let delayEffect = effect as? DelayEffect {
            delayEffect.isEnabled = false
            delayEffect.setBypass(true)
        }
    }
    
    // MARK: - Cleanup
    
    func removeAllEffects() {
        // Remove all track effects
        for trackId in trackEffects.keys {
            if let effects = trackEffects[trackId] {
                for effect in effects.effects.values {
                    detachEffectFromEngine(effect)
                }
            }
        }
        trackEffects.removeAll()
        
        // Remove all master effects
        for effect in masterEffects.effects.values {
            detachEffectFromMaster(effect)
        }
        masterEffects = MasterEffects()
    }
}
