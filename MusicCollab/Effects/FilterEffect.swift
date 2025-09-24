import Foundation
import AVFoundation

class FilterEffect: AudioEffect, ObservableObject {
    let id: String
    let name: String
    @Published var isEnabled: Bool = false
    @Published var parameters: FilterParameters
    
    private var _audioUnit: AVAudioUnitEQ?
    
    var audioUnit: AVAudioUnit? {
        return _audioUnit
    }
    
    init(id: String = UUID().uuidString, name: String = "Filter", parameters: FilterParameters = FilterParameters()) {
        self.id = id
        self.name = name
        self.parameters = parameters
        self.isEnabled = true  // Enable by default when created
    }
    
    func createAudioUnit() -> AVAudioUnit? {
        let eqUnit = AVAudioUnitEQ(numberOfBands: 1)
        _audioUnit = eqUnit
        
        // Ensure the effect is enabled and not bypassed
        isEnabled = true
        parameters.bypass = false
        
        updateParameters()
        return eqUnit
    }
    
    func updateParameters() {
        guard let eqUnit = _audioUnit else { return }
        
        let filter = eqUnit.bands[0]
        filter.filterType = avAudioUnitEQFilterType(from: parameters.filterType)
        filter.frequency = parameters.frequency
        // For AVAudioUnitEQ, bandwidth is used for Q calculation
        // Q = frequency / bandwidth, so bandwidth = frequency / Q
        filter.bandwidth = parameters.frequency / parameters.resonance
        filter.bypass = parameters.bypass
        filter.gain = 0.0 // No gain adjustment for filter
    }
    
    // MARK: - Parameter Updates
    
    func setFrequency(_ value: Float) {
        parameters.frequency = max(20.0, min(20000.0, value))
        updateParameters()
    }
    
    func setResonance(_ value: Float) {
        parameters.resonance = max(0.1, min(20.0, value))
        updateParameters()
    }
    
    func setFilterType(_ type: FilterType) {
        parameters.filterType = type
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
    
    // MARK: - Helper Methods
    
    private func avAudioUnitEQFilterType(from filterType: FilterType) -> AVAudioUnitEQFilterType {
        switch filterType {
        case .lowPass:
            return .lowPass
        case .highPass:
            return .highPass
        case .bandPass:
            return .bandPass
        case .bandStop:
            return .bandStop
        }
    }
    
    // MARK: - Frequency Conversion Helpers
    
    func frequencyToPercentage(_ frequency: Float) -> Float {
        // Convert frequency to logarithmic percentage (20Hz to 20kHz)
        let minFreq: Float = 20.0
        let maxFreq: Float = 20000.0
        let logMin = log10(minFreq)
        let logMax = log10(maxFreq)
        let logFreq = log10(frequency)
        
        return (logFreq - logMin) / (logMax - logMin)
    }
    
    func percentageToFrequency(_ percentage: Float) -> Float {
        // Convert logarithmic percentage to frequency
        let minFreq: Float = 20.0
        let maxFreq: Float = 20000.0
        let logMin = log10(minFreq)
        let logMax = log10(maxFreq)
        let logFreq = logMin + (percentage * (logMax - logMin))
        
        return pow(10, logFreq)
    }
    
    func frequencyDisplayString(_ frequency: Float) -> String {
        if frequency >= 1000 {
            return String(format: "%.1f kHz", frequency / 1000)
        } else {
            return String(format: "%.0f Hz", frequency)
        }
    }
}
