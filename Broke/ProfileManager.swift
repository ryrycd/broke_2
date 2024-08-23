//
//  ProfileManager.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//

import Foundation
import FamilyControls
import ManagedSettings

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var currentProfileId: UUID?
    
    init() {
        loadProfiles()
    }
    
    var currentProfile: Profile {
        (profiles.first(where: { $0.id == currentProfileId }) ?? profiles.first(where: { $0.name == "Default" }))!
    }
    
    func loadProfiles() {
        if let savedProfiles = UserDefaults.standard.data(forKey: "savedProfiles"),
           let decodedProfiles = try? JSONDecoder().decode([Profile].self, from: savedProfiles) {
            profiles = decodedProfiles
        } else {
            // Create a default profile if no profiles are saved
            let defaultProfile = Profile(name: "Default", appTokens: [], categoryTokens: [], icon: "house.circle")
            profiles = [defaultProfile]
            currentProfileId = defaultProfile.id
        }
        
        if let savedProfileId = UserDefaults.standard.string(forKey: "currentProfileId"),
           let uuid = UUID(uuidString: savedProfileId) {
            currentProfileId = uuid
        } else {
            currentProfileId = profiles.first?.id
        }
    }
    
    func saveProfiles() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: "savedProfiles")
        }
        UserDefaults.standard.set(currentProfileId?.uuidString, forKey: "currentProfileId")
    }
    
    func addProfile(name: String, icon: String = "person.circle") {
        let newProfile = Profile(name: name, appTokens: [], categoryTokens: [], icon: icon)
        profiles.append(newProfile)
        currentProfileId = newProfile.id
        saveProfiles()
    }
    
    func addProfile(newProfile: Profile) {
        profiles.append(newProfile)
        currentProfileId = newProfile.id
        saveProfiles()
    }
    
    func updateCurrentProfile(appTokens: Set<ApplicationToken>, categoryTokens: Set<ActivityCategoryToken>) {
        if let index = profiles.firstIndex(where: { $0.id == currentProfileId }) {
            profiles[index].appTokens = appTokens
            profiles[index].categoryTokens = categoryTokens
            saveProfiles()
        }
    }
    
    func setCurrentProfile(id: UUID) {
        if profiles.contains(where: { $0.id == id }) {
            currentProfileId = id
            saveProfiles()
        }
    }
    
    func deleteProfile(withId id: UUID) {
//        guard !profiles.first(where: { $0.id == id })?.isDefault ?? false else {
//            // Don't delete the default profile
//            return
//        }
        
        profiles.removeAll { $0.id == id }
        
        if currentProfileId == id {
            currentProfileId = profiles.first?.id
        }
        
        saveProfiles()
    }

    func deleteAllNonDefaultProfiles() {
        profiles.removeAll { !$0.isDefault }
        
        if !profiles.contains(where: { $0.id == currentProfileId }) {
            currentProfileId = profiles.first?.id
        }
        
        saveProfiles()
    }
    
    func updateCurrentProfile(name: String, iconName: String) {
        if let index = profiles.firstIndex(where: { $0.id == currentProfileId }) {
            profiles[index].name = name
            profiles[index].icon = iconName
            saveProfiles()
        }
    }

    func deleteCurrentProfile() {
        profiles.removeAll { $0.id == currentProfileId }
        if let firstProfile = profiles.first {
            currentProfileId = firstProfile.id
        }
        saveProfiles()
    }
}

struct Profile: Identifiable, Codable {
    let id = UUID()
    var name: String
    var appTokens: Set<ApplicationToken>
    var categoryTokens: Set<ActivityCategoryToken>
    var icon: String // New property for icon

    var isDefault: Bool {
        name == "Default"
    }

    // New initializer to support default icon
    init(name: String, appTokens: Set<ApplicationToken>, categoryTokens: Set<ActivityCategoryToken>, icon: String = "person.circle") {
        self.name = name
        self.appTokens = appTokens
        self.categoryTokens = categoryTokens
        self.icon = icon
    }
}