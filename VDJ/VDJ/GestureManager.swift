import SwiftUI

class GestureManager: ObservableObject {
    @Published var zoomScale: CGFloat = 1.0
    @Published var offset: CGSize = .zero
    
    func handleZoomGesture(scale: CGFloat) {
        zoomScale = scale
    }
    
    func handleDragGesture(translation: CGSize) {
        offset = translation
    }
}

