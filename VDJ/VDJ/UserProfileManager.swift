import Foundation
import Combine

struct UserProfile: Codable {
    let id: UUID
    var username: String
    var email: String
    var favoriteGenres: [String]
    var customPresets: [String]
    var achievements: [String]
    var createdAt: Date
    var lastActiveAt: Date
    
    init(username: String, email: String) {
        self.id = UUID()
        self.username = username
        self.email = email
        self.favoriteGenres = []
        self.customPresets = []
        self.achievements = []
        self.createdAt = Date()
        self.lastActiveAt = Date()
    }
}

class UserProfileManager: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isLoggedIn = false
    @Published var isLoading = false
    
    private let userDefaults = UserDefaults.standard
    private let userProfileKey = "VDJUserProfile"
    
    init() {
        loadUserProfile()
    }
    
    func signUp(username: String, email: String, password: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // In a real app, you'd make an API call here
            let newUser = UserProfile(username: username, email: email)
            
            DispatchQueue.main.async {
                self.currentUser = newUser
                self.isLoggedIn = true
                self.isLoading = false
                self.saveUserProfile()
                completion(.success(newUser))
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // In a real app, you'd validate credentials with a server
            if let savedUser = self.loadSavedProfile() {
                DispatchQueue.main.async {
                    self.currentUser = savedUser
                    self.isLoggedIn = true
                    self.isLoading = false
                    completion(.success(savedUser))
                }
            } else {
                let error = NSError(domain: "VDJAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signOut() {
        currentUser = nil
        isLoggedIn = false
        userDefaults.removeObject(forKey: userProfileKey)
    }
    
    func updateProfile(_ updatedProfile: UserProfile) {
        currentUser = updatedProfile
        saveUserProfile()
    }
    
    func addAchievement(_ achievement: String) {
        guard var user = currentUser else { return }
        if !user.achievements.contains(achievement) {
            user.achievements.append(achievement)
            updateProfile(user)
        }
    }
    
    func addCustomPreset(_ preset: String) {
        guard var user = currentUser else { return }
        user.customPresets.append(preset)
        updateProfile(user)
    }
    
    private func saveUserProfile() {
        guard let user = currentUser else { return }
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userProfileKey)
        }
    }
    
    private func loadUserProfile() {
        if let user = loadSavedProfile() {
            currentUser = user
            isLoggedIn = true
        }
    }
    
    private func loadSavedProfile() -> UserProfile? {
        guard let data = userDefaults.data(forKey: userProfileKey),
              let user = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return user
    }
}
