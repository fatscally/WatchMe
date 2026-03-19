import SwiftUI

struct ContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: connectivity.isOn ? "power.circle.fill" : "power.circle")
                .font(.system(size: 100, weight: .regular))
                .foregroundStyle(connectivity.isOn ? .green : .red)
            
            Text(connectivity.isOn ? "Power is ON" : "Power is OFF")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            // NEW: Show last received event time
            if let time = connectivity.lastEventTime {
                Text("Last change: \(time)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("No events yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary.opacity(0.6))
            }
            
            Text("iPhone and Apple Watch stay in sync")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 16) {
                Button {
                    connectivity.sendPowerState(isOn: true)
                } label: {
                    Text("On")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.plain)
                .background(connectivity.isOn ? Color.green : Color.gray.opacity(0.35))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                Button {
                    connectivity.sendPowerState(isOn: false)
                } label: {
                    Text("Off")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.plain)
                .background(connectivity.isOn ? Color.gray.opacity(0.35) : Color.red)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    ContentView()
}
