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
    
    // Real-time safe audio thread management
    private let audioQueue = DispatchQueue(label: "com.musiccollab.audio", qos: .userInteractive)
    private var audioThreadTimer: DispatchSourceTimer?
    private let audioThreadLock = NSLock()
    
    // Pre-allocated buffers for real-time safety
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    
    deinit {
        stopAudioThread()
        stopEngine()
    }
    
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
        setupRouteChangeNotification()
        
        // Configure audio session and start engine
        do {
            try configureAudioSession()
            startEngine()
        } catch {
            print("Failed to configure audio session: \(error)")
            // Try with minimal configuration
            do {
                try configureMinimalAudioSession()
                startEngine()
            } catch {
                print("Failed to configure minimal audio session: \(error)")
            }
        }
    }

    func startEngine() {
        guard !isStarted else { return }
        
        // Ensure engine is prepared and has nodes attached
        if !engine.isRunning {
            engine.prepare()
            
            // Verify engine has at least one node attached
            guard !engine.attachedNodes.isEmpty else {
                print("Error: No audio nodes attached to engine")
                return
            }
        }
        
        do {
            try engine.start()
            isStarted = true
            print("Audio engine started successfully")
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
        
        // Ensure audio engine is started and properly configured
        if !isStarted {
            startEngine()
        }
        
        // Double-check engine is running
        guard isStarted && engine.isRunning else {
            print("Error: Audio engine not running, cannot start playback")
            return
        }
        
        isPlaying = true
        state.isPlaying = true
        
        // Start the real-time safe audio thread for precise timing
        startAudioThread()
        
        print("Sequencer started")
    }
    
    func stopPlayback() {
        guard let state = sequencerState else { return }
        isPlaying = false
        state.isPlaying = false
        state.reset()
        
        stopAudioThread()
        print("Sequencer stopped")
    }
    
    func pausePlayback() {
        guard let state = sequencerState else { return }
        isPlaying = false
        state.isPlaying = false
        
        stopAudioThread()
        print("Sequencer paused")
    }
    
    private func startAudioThread() {
        guard sequencerState != nil else { return }
        
        // Stop any existing timer
        stopAudioThread()
        
        // Reset timing
        lastStepTime = CACurrentMediaTime()
        
        // Create high-priority timer on dedicated audio thread
        audioThreadTimer = DispatchSource.makeTimerSource(queue: audioQueue)
        audioThreadTimer?.schedule(deadline: .now(), repeating: .milliseconds(2)) // 2ms precision for real-time
        audioThreadTimer?.setEventHandler { [weak self] in
            self?.audioThreadTick()
        }
        audioThreadTimer?.resume()
    }
    
    private func stopAudioThread() {
        audioThreadTimer?.cancel()
        audioThreadTimer = nil
    }
    
    private func audioThreadTick() {
        // Real-time safe: minimal work, no allocations, no locks
        guard isPlaying else { return }
        
        // Get current state atomically
        let currentState = sequencerState
        guard let state = currentState else { return }
        
        // Calculate step duration based on current tempo
        let stepDuration = 60.0 / (state.currentPattern.tempo * 4) // 16th notes
        let currentTime = CACurrentMediaTime()
        
        // Check if it's time for the next step
        if currentTime - lastStepTime >= stepDuration {
            // Schedule audio operations on the audio queue
            audioQueue.async { [weak self] in
                self?.playCurrentStep()
            }
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
        
        // Move to next step - dispatch to main thread for UI updates
        DispatchQueue.main.async {
            state.nextStep()
        }
    }
    
    private func playSampleForTrack(_ track: Track, step: Step) {
        let sampleName = track.sampleName.lowercased()
        playSample(named: sampleName, volume: track.volume, pan: track.pan)
    }
    
    private func playSample(named sampleName: String, volume: Double = 1.0, pan: Double = 0.0) {
        // Ensure audio operations happen on the audio queue for thread safety
        audioQueue.async { [weak self] in
            guard let self = self,
                  let playerNode = self.playerNodes[sampleName],
                  let audioFile = self.audioFiles[sampleName] else {
                print("Sample not found: \(sampleName)")
                return
            }
            
            // Apply volume, pan, and master volume
            playerNode.volume = Float(volume) * self.masterVolume
            playerNode.pan = Float(pan)
            
            // Use pre-allocated buffer if available, otherwise schedule file
            if let buffer = self.audioBuffers[sampleName] {
                playerNode.stop()
                playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
                playerNode.play()
            } else {
                playerNode.stop()
                playerNode.scheduleFile(audioFile, at: nil) {
                    print("Played sample: \(sampleName) with volume: \(volume), pan: \(pan)")
                }
                playerNode.play()
            }
        }
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
        
        // Verify engine setup
        print("Audio engine setup complete - attached nodes: \(engine.attachedNodes.count)")
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
                
                // Pre-allocate buffer for real-time safety
                if let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length)) {
                    try audioFile.read(into: buffer)
                    audioBuffers[sampleName] = buffer
                    print("Pre-allocated buffer for sample: \(sampleName)")
                }
                
                print("Loaded sample: \(sampleName)")
            } catch {
                print("Failed to load sample \(sampleName): \(error)")
            }
        }
    }

    private func configureAudioSession() throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        
        // First deactivate the session to reset any previous configuration
        try session.setActive(false, options: [])
        
        // Set category with proper options for playback
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        
        // Set preferred sample rate (must be done before activating)
        try session.setPreferredSampleRate(44_100)
        
        // Set buffer duration for low latency
        try session.setPreferredIOBufferDuration(0.005) // 5ms for better compatibility
        
        // Activate the session
        try session.setActive(true)
        
        print("Audio session configured successfully - Sample rate: \(session.sampleRate)Hz, Buffer duration: \(session.ioBufferDuration)s")
        #else
        // No-op on non-iOS platforms
        #endif
    }
    
    private func configureMinimalAudioSession() throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        
        // Minimal configuration that should work on all devices
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
        
        print("Minimal audio session configured - Sample rate: \(session.sampleRate)Hz, Buffer duration: \(session.ioBufferDuration)s")
        #else
        // No-op on non-iOS platforms
        #endif
    }
    
    private func setupRouteChangeNotification() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        #endif
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        #if os(iOS)
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable, .newDeviceAvailable:
            // Restart engine when headphones are unplugged or new device connected
            if isStarted {
                stopEngine()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.startEngine()
                }
            }
        default:
            break
        }
        #endif
    }

    var mainMixer: AVAudioMixerNode { engine.mainMixerNode }
    var avEngine: AVAudioEngine { engine }
}
