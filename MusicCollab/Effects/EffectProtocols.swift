import Foundation
import AVFoundation

// MARK: - Effect Protocol

protocol AudioEffect {
    var id: String { get }
    var name: String { get }
    var isEnabled: Bool { get set }
    var audioUnit: AVAudioUnit? { get }
    
    func createAudioUnit() -> AVAudioUnit?
    func updateParameters()
}

// MARK: - Effect Types

enum EffectType: String, CaseIterable {
    case reverb = "reverb"
    case filter = "filter"
    case delay = "delay"
    
    var displayName: String {
        switch self {
        case .reverb:
            return "Reverb"
        case .filter:
            return "Filter"
        case .delay:
            return "Delay"
        }
    }
    
    var iconName: String {
        switch self {
        case .reverb:
            return "waveform"
        case .filter:
            return "slider.horizontal.3"
        case .delay:
            return "clock.arrow.circlepath"
        }
    }
}

// MARK: - Effect Parameters

struct ReverbParameters {
    var dryWetMix: Float = 0.5      // 0.0 = dry, 1.0 = wet - start with 50% wet for audible effect
    var preset: AVAudioUnitReverbPreset = .mediumRoom
    var bypass: Bool = false
}

struct FilterParameters {
    var frequency: Float = 2000.0    // 20Hz to 20kHz - start with 2kHz for more audible effect
    var resonance: Float = 2.0       // 0.1 to 20.0 - start with higher resonance for more audible effect
    var filterType: FilterType = .lowPass
    var bypass: Bool = false
}

enum FilterType: String, CaseIterable {
    case lowPass = "lowpass"
    case highPass = "highpass"
    case bandPass = "bandpass"
    case bandStop = "bandstop"
    
    var displayName: String {
        switch self {
        case .lowPass:
            return "Low Pass"
        case .highPass:
            return "High Pass"
        case .bandPass:
            return "Band Pass"
        case .bandStop:
            return "Band Stop"
        }
    }
}

// MARK: - Track Effects

class TrackEffects: ObservableObject {
    let trackId: String
    @Published var effects: [String: AudioEffect] = [:]
    
    init(trackId: String) {
        self.trackId = trackId
    }
    
    func addEffect(_ effect: AudioEffect) {
        effects[effect.id] = effect
    }
    
    func removeEffect(withId id: String) {
        effects.removeValue(forKey: id)
    }
    
    func getEffect(withId id: String) -> AudioEffect? {
        return effects[id]
    }
    
    var enabledEffects: [AudioEffect] {
        return effects.values.filter { $0.isEnabled }
    }
}

// MARK: - Master Effects

class MasterEffects: ObservableObject {
    @Published var effects: [String: AudioEffect] = [:]
    
    func addEffect(_ effect: AudioEffect) {
        effects[effect.id] = effect
    }
    
    func removeEffect(withId id: String) {
        effects.removeValue(forKey: id)
    }
    
    func getEffect(withId id: String) -> AudioEffect? {
        return effects[id]
    }
    
    var enabledEffects: [AudioEffect] {
        return effects.values.filter { $0.isEnabled }
    }
}
