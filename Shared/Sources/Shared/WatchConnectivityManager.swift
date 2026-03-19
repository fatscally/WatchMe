// WatchConnectivityManager.swift
// Shared between iOS and watchOS targets

import Foundation
import WatchConnectivity
import Combine

@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isOn: Bool = false
    
    private var session: WCSession?
    
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
        
        guard let session, session.activationState == .activated, session.isReachable else {
            // Fallback to context if not reachable yet
            updateContext(with: isOn)
            return
        }
        
        print("phone send")
        
        // Prefer sendMessage when both are active (faster UI feel)
        session.sendMessage(["power": isOn], replyHandler: nil) { error in
            print("sendMessage failed: \(error.localizedDescription) — falling back to context")
            self.updateContext(with: isOn)
        }
    }
    
    private func updateContext(with isOn: Bool) {
        guard let session else { return }
        do {
            try session.updateApplicationContext(["power": isOn])
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

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation: \(activationState), error: \(error?.localizedDescription ?? "none")")
        if activationState == .activated {
            // On activation, request current state from counterpart
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
        print("Phone didReceiveMessage: \(message)")
        handleIncoming(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext: \(applicationContext)")
        handleIncoming(applicationContext)
    }
    
    private func handleIncoming(_ dict: [String: Any]) {
        if let requested = dict["request"] as? String, requested == "power" {
            // Counterpart is asking for current state → send it back
            sendPowerState(isOn: isOn)
            return
        }
        
        if let power = dict["power"] as? Bool {
            DispatchQueue.main.async {
                self.isOn = power
            }
        }
    }
}

