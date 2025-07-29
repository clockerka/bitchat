//
// NotificationService.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import Foundation
import UserNotifications
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // Permission granted
            } else {
                // Permission denied
            }
        }
    }
    
    func sendLocalNotification(title: String, body: String, identifier: String, userInfo: [String: Any]? = nil) {
        // For now, skip app state check entirely to avoid thread issues
        // The NotificationDelegate will handle foreground presentation
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            if let userInfo = userInfo {
                content.userInfo = userInfo
            }
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: nil // Deliver immediately
            )
            
            UNUserNotificationCenter.current().add(request) { _ in
                // Notification added
            }
        }
    }
    
    func sendMentionNotification(from sender: String, message: String) {
        let title = String(format: NSLocalizedString("＠🫵 you were mentioned by %1$@", comment: ""), sender)
        let body = message
        let identifier = "mention-\(UUID().uuidString)"
        
        sendLocalNotification(title: title, body: body, identifier: identifier)
    }
    
    func sendPrivateMessageNotification(from sender: String, message: String, peerID: String) {
        let title = String(format: NSLocalizedString("🔒 private message from %1$@", comment: ""), sender)
        let body = message
        let identifier = "private-\(UUID().uuidString)"
        let userInfo = ["peerID": peerID, "senderName": sender]
        
        sendLocalNotification(title: title, body: body, identifier: identifier, userInfo: userInfo)
    }
    
    func sendFavoriteOnlineNotification(nickname: String) {
        // Send directly without checking app state for favorites
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = String(format: NSLocalizedString("⭐ %1$@ is online!", comment: ""), nickname)
            content.body = NSLocalizedString("wanna get in there?", comment: "")
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: "favorite-online-\(UUID().uuidString)",
                content: content,
                trigger: nil
            )
            
            UNUserNotificationCenter.current().add(request) { _ in
                // Notification added
            }
        }
    }
    
    func sendNetworkAvailableNotification(peerCount: Int) {
        let title = NSLocalizedString("👥 bitchatters nearby!", comment: "")
        let body = peerCount == 1 ? NSLocalizedString("1 person around", comment: "") : String(format: NSLocalizedString("%d people around", comment: ""), peerCount)
        let identifier = "network-available-\(Date().timeIntervalSince1970)"
        
        // For network notifications, we want to show them even in foreground
        // No app state check - let the notification delegate handle presentation
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.interruptionLevel = .timeSensitive  // Make it more prominent
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: nil // Deliver immediately
            )
            
            UNUserNotificationCenter.current().add(request) { _ in
                // Notification added
            }
        }
    }
}
