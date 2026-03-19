import Foundation
import Combine
import WatchConnectivity

@MainActor
final class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()

    @Published private(set) var isOn: Bool = false

    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    override private init() {
        super.init()
        session?.delegate = self
        session?.activate()
    }

    private func handleMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String, type == "powerState" else { return }
        if let value = message["isOn"] as? Bool {
            self.isOn = value
        }
    }
}

extension PhoneConnectivityManager: WCSessionDelegate {
    // iOS
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // No-op
    }

    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }

    // Immediate message from watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleMessage(message)
    }

    // Background delivery
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleMessage(userInfo)
    }
}
