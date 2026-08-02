import Foundation
import UIKit
import Social

class SocialSharingManager: ObservableObject {
    @Published var isSharing = false
    
    func shareVisualization(image: UIImage, text: String = "Check out this amazing visualization from VDJ!") {
        isSharing = true
        
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(
                activityItems: [text, image],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true) {
                    self.isSharing = false
                }
            }
        }
    }
    
    func sharePlaylist(playlistName: String, tracks: [String]) {
        isSharing = true
        
        let playlistText = """
        🎵 My VDJ Playlist: \(playlistName)
        
        \(tracks.prefix(5).enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        \(tracks.count > 5 ? "\n... and \(tracks.count - 5) more tracks!" : "")
        
        Created with VDJ - The Ultimate Music Visualizer
        """
        
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(
                activityItems: [playlistText],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true) {
                    self.isSharing = false
                }
            }
        }
    }
    
    func shareToInstagramStories(image: UIImage) {
        guard let instagramURL = URL(string: "instagram-stories://share") else {
            print("Instagram not installed")
            return
        }
        
        if UIApplication.shared.canOpenURL(instagramURL) {
            // Convert image to data
            guard let imageData = image.pngData() else { return }
            
            // Create pasteboard items
            let pasteboardItems: [String: Any] = [
                "com.instagram.sharedSticker.stickerImage": imageData,
                "com.instagram.sharedSticker.backgroundTopColor": "#FF6B6B",
                "com.instagram.sharedSticker.backgroundBottomColor": "#4ECDC4"
            ]
            
            let pasteboard = UIPasteboard.general
            pasteboard.setItems([pasteboardItems])
            
            UIApplication.shared.open(instagramURL)
        }
    }
}
