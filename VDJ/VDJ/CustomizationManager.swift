import SwiftUI
import Foundation

class CustomizationManager: ObservableObject {
    @Published var primaryColor: Color = .blue
    @Published var secondaryColor: Color = .purple
    @Published var effectIntensity: Double = 0.5
    @Published var animationSpeed: Double = 1.0
    @Published var particleDensity: Double = 1.0
    @Published var bloomRadius: Double = 10.0
    @Published var kaleidoscopeCount: Int = 8
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        // Save color as data
        if let primaryColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(primaryColor), requiringSecureCoding: false) {
            userDefaults.set(primaryColorData, forKey: "primaryColor")
        }
        if let secondaryColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(secondaryColor), requiringSecureCoding: false) {
            userDefaults.set(secondaryColorData, forKey: "secondaryColor")
        }
        
        userDefaults.set(effectIntensity, forKey: "effectIntensity")
        userDefaults.set(animationSpeed, forKey: "animationSpeed")
        userDefaults.set(particleDensity, forKey: "particleDensity")
        userDefaults.set(bloomRadius, forKey: "bloomRadius")
        userDefaults.set(kaleidoscopeCount, forKey: "kaleidoscopeCount")
    }
    
    func loadSettings() {
        if let primaryColorData = userDefaults.data(forKey: "primaryColor"),
           let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(primaryColorData) as? UIColor {
            primaryColor = Color(uiColor)
        }
        
        if let secondaryColorData = userDefaults.data(forKey: "secondaryColor"),
           let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(secondaryColorData) as? UIColor {
            secondaryColor = Color(uiColor)
        }
        
        effectIntensity = userDefaults.double(forKey: "effectIntensity")
        if effectIntensity == 0 { effectIntensity = 0.5 }
        
        animationSpeed = userDefaults.double(forKey: "animationSpeed")
        if animationSpeed == 0 { animationSpeed = 1.0 }
        
        particleDensity = userDefaults.double(forKey: "particleDensity")
        if particleDensity == 0 { particleDensity = 1.0 }
        
        bloomRadius = userDefaults.double(forKey: "bloomRadius")
        if bloomRadius == 0 { bloomRadius = 10.0 }
        
        kaleidoscopeCount = userDefaults.integer(forKey: "kaleidoscopeCount")
        if kaleidoscopeCount == 0 { kaleidoscopeCount = 8 }
    }
    
    func resetToDefaults() {
        primaryColor = .blue
        secondaryColor = .purple
        effectIntensity = 0.5
        animationSpeed = 1.0
        particleDensity = 1.0
        bloomRadius = 10.0
        kaleidoscopeCount = 8
        saveSettings()
    }
}
