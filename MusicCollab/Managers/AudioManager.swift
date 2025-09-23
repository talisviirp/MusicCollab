import Foundation
import AVFoundation
import QuartzCore

final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private let engine = AVAudioEngine()
    private var isStarted = false
    private var isPlaying = false
    private var sequencer: AVAudioSequencer?
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var audioFiles: [String: AVAudioFile] = [:]
    private var sequencerState: SequencerState?
    private var sequencerTimer: Timer?
    private var lastStepTime: CFTimeInterval = 0
    private var displayLink: CADisplayLink?
    private var masterVolume: Float = 1.0
    
    // Sample file names
    private let sampleFiles = [
        "kick": "kick",
        "snare": "snare", 
        "hihat": "hiHat",
        "hihat2": "hiHat2"
    ]

    private init() {
        setupAudioEngine()
        loadSamples()
    }

    func startEngine() {
        guard !isStarted else { return }
        do {
            try configureAudioSession()
            try engine.start()
            isStarted = true
            print("Audio engine started")
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    func stopEngine() {
        guard isStarted else { return }
        engine.stop()
        isStarted = false
        print("Audio engine stopped")
    }
    
    // MARK: - Sample Playback
    
    func playSample() {
        playKick() // Default sample
    }
    
    func playKick() {
        playSample(named: "kick")
    }
    
    func playSnare() {
        playSample(named: "snare")
    }
    
    func playHiHat() {
        playSample(named: "hihat")
    }
    
    func playHiHat2() {
        playSample(named: "hihat2")
    }
    
    private func playSample(named sampleName: String) {
        playSample(named: sampleName, volume: 1.0, pan: 0.0)
    }
    
    // MARK: - Sequencer Controls
    
    func setSequencerState(_ state: SequencerState) {
        self.sequencerState = state
    }
    
    func updateTempo(_ newTempo: Double) {
        guard let state = sequencerState else { return }
        
        // Update the pattern's tempo
        state.currentPattern.tempo = newTempo
        
        // No need to restart anything - the display link will handle the new tempo
        print("Tempo updated to \(newTempo) BPM")
    }
    
    func updateMasterVolume(_ volume: Double) {
        masterVolume = Float(volume)
        print("Master volume updated to \(Int(volume * 100))%")
    }
    
    func startPlayback() {
        guard let state = sequencerState else { return }
        isPlaying = true
        state.isPlaying = true
        
        // Start the sequencer display link for precise timing
        startSequencerDisplayLink()
        
        print("Sequencer started")
    }
    
    func stopPlayback() {
        guard let state = sequencerState else { return }
        isPlaying = false
        state.isPlaying = false
        state.reset()
        
        stopSequencerDisplayLink()
        print("Sequencer stopped")
    }
    
    func pausePlayback() {
        guard let state = sequencerState else { return }
        isPlaying = false
        state.isPlaying = false
        
        stopSequencerDisplayLink()
        print("Sequencer paused")
    }
    
    private func startSequencerDisplayLink() {
        guard let state = sequencerState else { return }
        
        // Reset timing
        lastStepTime = CACurrentMediaTime()
        
        // Create display link for precise timing
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopSequencerDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func displayLinkTick() {
        guard let state = sequencerState, isPlaying else { return }
        
        // Calculate step duration based on current tempo
        let stepDuration = 60.0 / (state.currentPattern.tempo * 4) // 16th notes
        let currentTime = CACurrentMediaTime()
        
        // Check if it's time for the next step
        if currentTime - lastStepTime >= stepDuration {
            playCurrentStep()
            lastStepTime = currentTime
        }
    }
    
    private func playCurrentStep() {
        guard let state = sequencerState, isPlaying else { return }
        
        let currentStep = state.currentStep
        let pattern = state.currentPattern
        
        // Check if any tracks are soloed
        let hasSoloedTracks = pattern.tracks.contains { $0.isSoloed }
        
        // Play all active steps for this beat
        for track in pattern.tracks {
            let shouldPlay: Bool
            if hasSoloedTracks {
                // If any track is soloed, only play soloed tracks
                shouldPlay = track.isSoloed && !track.isMuted && currentStep < track.steps.count && track.steps[currentStep].isActive
            } else {
                // If no tracks are soloed, play all non-muted tracks
                shouldPlay = !track.isMuted && currentStep < track.steps.count && track.steps[currentStep].isActive
            }
            
            if shouldPlay {
                playSampleForTrack(track, step: track.steps[currentStep])
            }
        }
        
        // Move to next step
        state.nextStep()
    }
    
    private func playSampleForTrack(_ track: Track, step: Step) {
        let sampleName = track.sampleName.lowercased()
        playSample(named: sampleName, volume: track.volume, pan: track.pan)
    }
    
    private func playSample(named sampleName: String, volume: Double = 1.0, pan: Double = 0.0) {
        guard let playerNode = playerNodes[sampleName],
              let audioFile = audioFiles[sampleName] else {
            print("Sample not found: \(sampleName)")
            return
        }
        
        // Apply volume, pan, and master volume
        playerNode.volume = Float(volume) * masterVolume
        playerNode.pan = Float(pan)
        
        playerNode.stop()
        playerNode.scheduleFile(audioFile, at: nil) {
            print("Played sample: \(sampleName) with volume: \(volume), pan: \(pan)")
        }
        playerNode.play()
    }
    
    // MARK: - Private Setup Methods
    
    private func setupAudioEngine() {
        // Create player nodes for each sample
        for sampleName in sampleFiles.keys {
            let playerNode = AVAudioPlayerNode()
            playerNodes[sampleName] = playerNode
            engine.attach(playerNode)
            engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        }
        
        // Setup sequencer
        sequencer = AVAudioSequencer(audioEngine: engine)
    }
    
    private func loadSamples() {
        for (sampleName, fileName) in sampleFiles {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
                print("Could not find sample file: \(fileName).mp3")
                continue
            }
            
            do {
                let audioFile = try AVAudioFile(forReading: url)
                audioFiles[sampleName] = audioFile
                print("Loaded sample: \(sampleName)")
            } catch {
                print("Failed to load sample \(sampleName): \(error)")
            }
        }
    }

    private func configureAudioSession() throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetoothHFP])
        try session.setPreferredSampleRate(44_100)
        try session.setPreferredIOBufferDuration(0.005) // Low latency for real-time audio
        try session.setActive(true)
        print("Audio session configured for low-latency playback")
        #else
        // No-op on non-iOS platforms
        #endif
    }

    var mainMixer: AVAudioMixerNode { engine.mainMixerNode }
    var avEngine: AVAudioEngine { engine }
}
