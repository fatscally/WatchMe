// WatchConnectivityManager.swift
// Shared between iOS and watchOS targets

import Foundation
import WatchConnectivity
import Combine

@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isOn: Bool = false
    @Published var lastEventTime: String? = nil  // ← NEW: last received event time
    
    private var session: WCSession?
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = .current
        return formatter
    }()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func sendPowerState(isOn: Bool) {
        self.isOn = isOn  // Update local UI immediately
        
        let now = Date()
        let timeString = timeFormatter.string(from: now)
        let payload: [String: Any] = [
            "power": isOn,
            "time": timeString
        ]
        
        guard let session else { return }
        
        if session.isReachable {
            print("Sending message with time: \(timeString)")
            session.sendMessage(payload, replyHandler: nil) { error in
                print("sendMessage failed: \(error.localizedDescription) — falling back to context")
                self.updateContext(with: payload)
            }
        } else {
            updateContext(with: payload)
        }
    }
    
    private func updateContext(with payload: [String: Any]) {
        guard let session else { return }
        do {
            try session.updateApplicationContext(payload)
            print("Context updated with time: \(payload["time"] ?? "n/a")")
        } catch {
            print("updateApplicationContext failed: \(error)")
        }
    }
    
    private func requestCurrentStateIfNeeded() {
        guard let session, session.isReachable else { return }
        session.sendMessage(["request": "power"], replyHandler: nil) { error in
            print("Request power state failed: \(error)")
        }
    }
}

extension WatchConnectivityManager: @MainActor WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation: \(activationState), error: \(error?.localizedDescription ?? "none")")
        if activationState == .activated {
            requestCurrentStateIfNeeded()
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Reachability changed: \(session.isReachable)")
        if session.isReachable {
            requestCurrentStateIfNeeded()
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
    
    // MARK: - Receiving
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage: \(message)")
        handleIncoming(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext: \(applicationContext)")
        handleIncoming(applicationContext)
    }
    
    private func handleIncoming(_ dict: [String: Any]) {
        if let requested = dict["request"] as? String, requested == "power" {
            // Counterpart asking for current state → send it back (with current time)
            sendPowerState(isOn: isOn)
            return
        }
        
        if let power = dict["power"] as? Bool,
           let timeStr = dict["time"] as? String {
            self.isOn = power
            self.lastEventTime = timeStr  // ← NEW: store received time
            print("Updated state to \(power) at \(timeStr)")
        }
    }
}
