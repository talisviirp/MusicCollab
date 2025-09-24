import Foundation
import AVFoundation
import Combine

// MARK: - Delay Parameters
struct DelayParameters {
    var delayTime: Double = 0.5        // Delay time in seconds (0.0 to 2.0)
    var feedback: Float = 50.0         // Feedback amount (0.0 to 100.0)
    var wetDryMix: Float = 50.0        // Wet/Dry mix (0.0 to 100.0)
    var bypass: Bool = false           // Bypass the effect
}

// MARK: - Delay Effect
class DelayEffect: AudioEffect, ObservableObject {
    let id = UUID().uuidString
    let name = "Delay"
    let type: EffectType = .delay
    
    @Published var isEnabled: Bool = true
    @Published var parameters = DelayParameters()
    
    private var _audioUnit: AVAudioUnit?
    var audioUnit: AVAudioUnit? {
        return _audioUnit
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupParameterObservers()
    }
    
    // MARK: - Audio Unit Creation
    func createAudioUnit() -> AVAudioUnit? {
        let delayUnit = AVAudioUnitDelay()
        _audioUnit = delayUnit
        
        // Ensure the effect is enabled and not bypassed
        isEnabled = true
        parameters.bypass = false
        
        // Set parameters to audible values
        parameters.delayTime = 0.5      // 500ms delay
        parameters.feedback = 30.0      // 30% feedback for subtle effect
        parameters.wetDryMix = 30.0     // 30% wet for subtle effect
        
        print("Created delay unit with delayTime: \(delayUnit.delayTime), feedback: \(delayUnit.feedback), wetDryMix: \(delayUnit.wetDryMix)")
        
        updateParameters()
        return delayUnit
    }
    
    // MARK: - Parameter Updates
    func updateParameters() {
        guard let delayUnit = _audioUnit as? AVAudioUnitDelay else { return }
        
        // Update delay unit parameters
        delayUnit.delayTime = parameters.delayTime
        delayUnit.feedback = parameters.feedback
        delayUnit.wetDryMix = parameters.wetDryMix
        delayUnit.bypass = parameters.bypass
        
        print("Delay parameters updated - delayTime: \(parameters.delayTime), feedback: \(parameters.feedback), wetDryMix: \(parameters.wetDryMix), bypass: \(parameters.bypass)")
    }
    
    // MARK: - Parameter Observers
    private func setupParameterObservers() {
        // Observe delay time changes
        $parameters
            .map(\.delayTime)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateParameters()
            }
            .store(in: &cancellables)
        
        // Observe feedback changes
        $parameters
            .map(\.feedback)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateParameters()
            }
            .store(in: &cancellables)
        
        // Observe wet/dry mix changes
        $parameters
            .map(\.wetDryMix)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateParameters()
            }
            .store(in: &cancellables)
        
        // Observe bypass changes
        $parameters
            .map(\.bypass)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateParameters()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Effect Control
    func setBypass(_ bypass: Bool) {
        parameters.bypass = bypass
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            setBypass(true)
        }
    }
    
    // MARK: - Parameter Setters
    func setDelayTime(_ time: Double) {
        let clampedTime = max(0.0, min(2.0, time))
        parameters.delayTime = clampedTime
    }
    
    func setFeedback(_ feedback: Float) {
        let clampedFeedback = max(0.0, min(100.0, feedback))
        parameters.feedback = clampedFeedback
    }
    
    func setWetDryMix(_ mix: Float) {
        let clampedMix = max(0.0, min(100.0, mix))
        parameters.wetDryMix = clampedMix
    }
    
    // MARK: - Preset Management
    func resetToDefaults() {
        parameters = DelayParameters()
        updateParameters()
    }
    
    func applyPreset(_ preset: DelayPreset) {
        switch preset {
        case .short:
            parameters.delayTime = 0.25
            parameters.feedback = 20.0
            parameters.wetDryMix = 25.0
        case .medium:
            parameters.delayTime = 0.5
            parameters.feedback = 30.0
            parameters.wetDryMix = 30.0
        case .long:
            parameters.delayTime = 1.0
            parameters.feedback = 40.0
            parameters.wetDryMix = 35.0
        case .slapback:
            parameters.delayTime = 0.125
            parameters.feedback = 10.0
            parameters.wetDryMix = 40.0
        case .pingPong:
            parameters.delayTime = 0.375
            parameters.feedback = 60.0
            parameters.wetDryMix = 50.0
        }
        updateParameters()
    }
}

// MARK: - Delay Presets
enum DelayPreset: String, CaseIterable {
    case short = "Short"
    case medium = "Medium"
    case long = "Long"
    case slapback = "Slapback"
    case pingPong = "Ping Pong"
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .short:
            return "Quick, subtle delay"
        case .medium:
            return "Balanced delay effect"
        case .long:
            return "Long, spacious delay"
        case .slapback:
            return "Classic rock slapback"
        case .pingPong:
            return "Stereo ping-pong delay"
        }
    }
}
