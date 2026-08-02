import Foundation
import AVFoundation

class DAWManager: ObservableObject {
    @Published var isRecording = false
    @Published var tracks: [AudioTrack] = []
    @Published var currentPosition: TimeInterval = 0
    
    private var audioEngine = AVAudioEngine()
    private var audioRecorder: AVAudioRecorder?
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        // Configure audio engine for multi-track support
        let inputNode = audioEngine.inputNode
        let outputNode = audioEngine.outputNode
        
        // Set up audio session
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        if let url = audioRecorder?.url {
            let newTrack = AudioTrack(name: "Recording \(tracks.count + 1)", url: url)
            tracks.append(newTrack)
        }
    }
    
    func addTrack(url: URL, name: String) {
        let track = AudioTrack(name: name, url: url)
        tracks.append(track)
    }
    
    func removeTrack(at index: Int) {
        guard index < tracks.count else { return }
        tracks.remove(at: index)
    }
    
    func mixTracks() -> URL? {
        // Simplified mixing - in a real DAW, this would be much more complex
        guard !tracks.isEmpty else { return nil }
        
        // For now, just return the first track's URL
        // In a real implementation, you'd mix all tracks together
        return tracks.first?.url
    }
}

struct AudioTrack: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    var volume: Float = 1.0
    var isMuted = false
    var isSolo = false
}
