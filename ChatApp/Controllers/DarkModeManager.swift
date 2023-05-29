//
//  DarkModeManager.swift
//  ChatApp
//
//  Created by Eduardo  Moraza on 25/5/2023.
//

import UIKit

class DarkModeManager {
    
    static let shared = DarkModeManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    var isDarkModeEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDarkModeEnabled")
            UserDefaults.standard.synchronize()
        }
    }
    
    func toggleDarkMode() {
        isDarkModeEnabled = !isDarkModeEnabled
        updateAppearance()
    }
    
    func updateAppearance() {
        let isDarkModeEnabled = self.isDarkModeEnabled 
        if isDarkModeEnabled {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
    }
    
    func saveSettings(){
        userDefaults.set(isDarkModeEnabled, forKey: "isDarkModeEnabled")
        userDefaults.synchronize()
    }
}
