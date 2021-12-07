//
//  SettingsService.swift
//  HorsZone
//
//  Created by Yoan on 03/12/2021.
//

import Foundation

class SettingService {
    private struct Keys {
        static let language = "language"
    }

    static var language: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.language) ?? "Language"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.language)
        }
    }
}
