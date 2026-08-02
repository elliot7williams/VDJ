import Foundation
import AVFoundation

class StreamManager: NSObject, ObservableObject {
    private var playerItemContext = 0
    private var player: AVPlayer?
    @Published var isBuffering = false
    
    override init() {
        super.init()
        // Initialization code here
    }
    
    func startStreaming(from url: URL) {
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: &playerItemContext)
        player?.play()
    }
    
    // Observe the player's time control status to update the buffering state
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &playerItemContext {
            if let player = object as? AVPlayer, player == self.player {
                switch player.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    isBuffering = true
                default:
                    isBuffering = false
                }
            }
        }
    }
    
    deinit {
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
}

