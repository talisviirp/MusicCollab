import Foundation

// MARK: - Step Model
struct Step: Identifiable, Codable, Hashable {
    let id: UUID
    var isActive: Bool
    var velocity: Double // 0.0 to 1.0
    var note: Int // MIDI note number
    var duration: Double // Step duration in beats
    
    init(id: UUID = UUID(), isActive: Bool = false, velocity: Double = 0.8, note: Int = 60, duration: Double = 0.25) {
        self.id = id
        self.isActive = isActive
        self.velocity = velocity
        self.note = note
        self.duration = duration
    }
}

// MARK: - Track Model
class Track: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var steps: [Step]
    @Published var isMuted: Bool
    @Published var isSoloed: Bool
    @Published var volume: Double // 0.0 to 1.0
    @Published var pan: Double // -1.0 to 1.0
    @Published var sampleName: String
    
    init(id: UUID = UUID(), name: String, steps: [Step] = [], isMuted: Bool = false, isSoloed: Bool = false, volume: Double = 0.8, pan: Double = 0.0, sampleName: String = "kick") {
        self.id = id
        self.name = name
        self.steps = steps.isEmpty ? Self.createEmptySteps() : steps
        self.isMuted = isMuted
        self.isSoloed = isSoloed
        self.volume = volume
        self.pan = pan
        self.sampleName = sampleName
    }
    
    private static func createEmptySteps() -> [Step] {
        return (0..<16).map { _ in Step() }
    }
    
    func toggleStep(at index: Int) {
        guard index >= 0 && index < steps.count else { return }
        objectWillChange.send()
        steps[index].isActive.toggle()
    }
    
    func setStep(at index: Int, isActive: Bool) {
        guard index >= 0 && index < steps.count else { return }
        objectWillChange.send()
        steps[index].isActive = isActive
    }
}

// MARK: - Pattern Model
class Pattern: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var tracks: [Track]
    @Published var tempo: Double // BPM
    @Published var timeSignature: TimeSignature
    @Published var length: Int // Number of steps
    
    init(id: UUID = UUID(), name: String = "Pattern 1", tracks: [Track] = [], tempo: Double = 120.0, timeSignature: TimeSignature = TimeSignature(), length: Int = 16) {
        self.id = id
        self.name = name
        self.tracks = tracks.isEmpty ? Self.createDefaultTracks() : tracks
        self.tempo = tempo
        self.timeSignature = timeSignature
        self.length = length
    }
    
    private static func createDefaultTracks() -> [Track] {
        return [
            Track(name: "Kick", sampleName: "kick"),
            Track(name: "Snare", sampleName: "snare"),
            Track(name: "Hi-Hat", sampleName: "hiHat"),
            Track(name: "Hi-Hat 2", sampleName: "hiHat2")
        ]
    }
    
    func toggleStep(trackId: UUID, stepIndex: Int) {
        if let trackIndex = tracks.firstIndex(where: { $0.id == trackId }) {
            tracks[trackIndex].toggleStep(at: stepIndex)
        }
    }
    
    func setStep(trackId: UUID, stepIndex: Int, isActive: Bool) {
        if let trackIndex = tracks.firstIndex(where: { $0.id == trackId }) {
            tracks[trackIndex].setStep(at: stepIndex, isActive: isActive)
        }
    }
}

// MARK: - Time Signature Model
struct TimeSignature: Codable, Hashable {
    var numerator: Int
    var denominator: Int
    
    init(numerator: Int = 4, denominator: Int = 4) {
        self.numerator = numerator
        self.denominator = denominator
    }
    
    var displayString: String {
        return "\(numerator)/\(denominator)"
    }
}

// MARK: - Sequencer State
class SequencerState: ObservableObject {
    @Published var currentPattern: Pattern
    @Published var isPlaying: Bool = false
    @Published var currentStep: Int = 0
    @Published var loopStart: Int = 0
    @Published var loopEnd: Int = 15
    
    init(pattern: Pattern = Pattern()) {
        self.currentPattern = pattern
    }
    
    func toggleStep(trackId: UUID, stepIndex: Int) {
        currentPattern.toggleStep(trackId: trackId, stepIndex: stepIndex)
    }
    
    func setStep(trackId: UUID, stepIndex: Int, isActive: Bool) {
        currentPattern.setStep(trackId: trackId, stepIndex: stepIndex, isActive: isActive)
    }
    
    func updateTempo(_ tempo: Double) {
        currentPattern.tempo = tempo
    }
    
    func reset() {
        currentStep = 0
        isPlaying = false
    }
    
    func nextStep() {
        currentStep = (currentStep + 1) % currentPattern.length
    }
}

// MARK: - Mock Data
extension Pattern {
    static let mockPattern: Pattern = {
        var pattern = Pattern(name: "Demo Pattern")
        
        // Add some demo steps
        pattern.setStep(trackId: pattern.tracks[0].id, stepIndex: 0, isActive: true) // Kick on 1
        pattern.setStep(trackId: pattern.tracks[0].id, stepIndex: 4, isActive: true) // Kick on 5
        pattern.setStep(trackId: pattern.tracks[0].id, stepIndex: 8, isActive: true) // Kick on 9
        pattern.setStep(trackId: pattern.tracks[0].id, stepIndex: 12, isActive: true) // Kick on 13
        
        pattern.setStep(trackId: pattern.tracks[1].id, stepIndex: 4, isActive: true) // Snare on 5
        pattern.setStep(trackId: pattern.tracks[1].id, stepIndex: 12, isActive: true) // Snare on 13
        
        // Hi-hat pattern
        for i in stride(from: 0, to: 16, by: 2) {
            pattern.setStep(trackId: pattern.tracks[2].id, stepIndex: i, isActive: true)
        }
        
        return pattern
    }()
}
