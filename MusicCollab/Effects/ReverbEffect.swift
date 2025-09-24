import Foundation
import AVFoundation

class ReverbEffect: AudioEffect, ObservableObject {
    let id: String
    let name: String
    @Published var isEnabled: Bool = false
    @Published var parameters: ReverbParameters
    
    private var _audioUnit: AVAudioUnitReverb?
    private var currentPreset: AVAudioUnitReverbPreset = .mediumRoom
    
    var audioUnit: AVAudioUnit? {
        return _audioUnit
    }
    
    init(id: String = UUID().uuidString, name: String = "Reverb", parameters: ReverbParameters = ReverbParameters()) {
        self.id = id
        self.name = name
        self.parameters = parameters
        self.isEnabled = true  // Enable by default when created
    }
    
    func createAudioUnit() -> AVAudioUnit? {
        let reverbUnit = AVAudioUnitReverb()
        _audioUnit = reverbUnit
        
        // Ensure the effect is enabled and not bypassed
        isEnabled = true
        parameters.bypass = false
        
        // Set parameters to more audible values before calling updateParameters
        parameters.dryWetMix = 0.5  // Set parameter to 50% wet for audible effect
        parameters.preset = .largeHall  // Use a more dramatic preset
        currentPreset = parameters.preset  // Track the current preset
        
        // Configure the reverb unit immediately
        reverbUnit.loadFactoryPreset(parameters.preset)
        reverbUnit.wetDryMix = parameters.dryWetMix
        reverbUnit.bypass = parameters.bypass
        
        print("Created reverb unit with wetDryMix: \(reverbUnit.wetDryMix), preset: \(parameters.preset), bypass: \(reverbUnit.bypass)")
        print("Reverb unit input format: \(reverbUnit.inputFormat(forBus: 0))")
        print("Reverb unit output format: \(reverbUnit.outputFormat(forBus: 0))")
        
        updateParameters()
        return reverbUnit
    }
    
    func updateParameters() {
        guard let reverbUnit = _audioUnit else { 
            print("ReverbEffect: No audio unit available for parameter update")
            return 
        }
        
        // Only call loadFactoryPreset if the preset has changed
        if currentPreset != parameters.preset {
            reverbUnit.loadFactoryPreset(parameters.preset)
            currentPreset = parameters.preset
            print("ReverbEffect: Loaded preset: \(parameters.preset)")
        }
        
        // Update parameters without recreating the unit
        reverbUnit.bypass = parameters.bypass
        reverbUnit.wetDryMix = parameters.dryWetMix
        
        print("ReverbEffect: Updated parameters - wetDryMix: \(reverbUnit.wetDryMix), preset: \(parameters.preset), bypass: \(reverbUnit.bypass)")
    }
    
    // MARK: - Parameter Updates
    
    func setDryWetMix(_ value: Float) {
        parameters.dryWetMix = max(0.0, min(1.0, value))
        updateParameters()
    }
    
    func setPreset(_ preset: AVAudioUnitReverbPreset) {
        parameters.preset = preset
        updateParameters()
    }
    
    func setBypass(_ bypass: Bool) {
        parameters.bypass = bypass
        updateParameters()
    }
    
    func toggleEnabled() {
        isEnabled.toggle()
        if isEnabled {
            parameters.bypass = false
        } else {
            parameters.bypass = true
        }
        updateParameters()
    }
}

// MARK: - Reverb Preset Extensions

extension AVAudioUnitReverbPreset: @retroactive CaseIterable {
    public static var allCases: [AVAudioUnitReverbPreset] {
        return [
            .smallRoom,
            .mediumRoom,
            .largeRoom,
            .mediumHall,
            .largeHall,
            .plate,
            .mediumChamber,
            .largeChamber,
            .cathedral,
            .largeRoom2,
            .mediumHall2,
            .mediumHall3,
            .largeHall2
        ]
    }
    
    var displayName: String {
        switch self {
        case .smallRoom:
            return "Small Room"
        case .mediumRoom:
            return "Medium Room"
        case .largeRoom:
            return "Large Room"
        case .mediumHall:
            return "Medium Hall"
        case .largeHall:
            return "Large Hall"
        case .plate:
            return "Plate"
        case .mediumChamber:
            return "Medium Chamber"
        case .largeChamber:
            return "Large Chamber"
        case .cathedral:
            return "Cathedral"
        case .largeRoom2:
            return "Large Room 2"
        case .mediumHall2:
            return "Medium Hall 2"
        case .mediumHall3:
            return "Medium Hall 3"
        case .largeHall2:
            return "Large Hall 2"
        @unknown default:
            return "Unknown"
        }
    }
}
