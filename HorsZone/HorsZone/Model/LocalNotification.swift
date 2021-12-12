//
//  LocalNotification.swift
//  HorsZone
//
//  Created by Yoan on 30/11/2021.
//

import Foundation
import UIKit

class LocalNotification {
    let notificationCenter = UNUserNotificationCenter.current()
    let notification = UNMutableNotificationContent()
    let translateText = Translate()

    func notificationInitialize() {
        prepareMyAlert()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            if granted {
            }
        }
    }

    func sendNotification() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier:
                                                            UUID().uuidString, content: notification, trigger: trigger)
        notificationCenter.add(notificationRequest)
    }

    private func prepareMyAlert() {

        notification.title = "Attention !!!"
        notification.body = translateText.alertLeftZoneMessage()
        notification.categoryIdentifier = "StopMonitoring.category"
        notification.badge = 1
        notification.sound = UNNotificationSound.default

//        setActionCategories()
    }

    private func setActionCategories() {
        let stopMonitoring = UNNotificationAction(
            identifier: "Stop monitoring",
            title: "Arrêter le suivi",
            options: [])

        let stopCategory = UNNotificationCategory(
            identifier: "StopMonitoring.category",
            actions: [stopMonitoring],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: [.customDismissAction])

        notificationCenter.setNotificationCategories([stopCategory])
    }

}
