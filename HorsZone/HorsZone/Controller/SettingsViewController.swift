//
//  SettingsViewController.swift
//  HorsZone
//
//  Created by Yoan on 12/11/2021.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController, UNUserNotificationCenterDelegate {

    
    // MARK: - Properties
    let center = UNUserNotificationCenter.current()
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationInitialize()
    }
    
    
    // MARK: - private function
    
    private func notificationInitialize() {
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                
            }
        }
        
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional) else { return }
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification.
            } else {
                // Schedule a notification with a badge and sound.
            }
        }
    }
    
    private func presentAlert_Alert (alertTitle title: String = "Erreur", alertMessage message: String, buttonTitle titleButton: String = "Ok", alertStyle style: UIAlertAction.Style = .cancel) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButton, style: style, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
}
