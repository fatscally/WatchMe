import SwiftUI

struct ContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: connectivity.isOn ? "power.circle.fill" : "power.circle")
                .font(.system(size: 56, weight: .regular))
                .foregroundStyle(connectivity.isOn ? .green : .red)

            Text(connectivity.isOn ? "Power is ON" : "Power is OFF")
                .font(.headline)

            HStack(spacing: 8) {
                Button {
                    connectivity.sendPowerState(isOn: true)
                } label: {
                    Text("On")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
                .background(connectivity.isOn ? Color.green : Color.gray.opacity(0.35))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Button {
                    connectivity.sendPowerState(isOn: false)
                } label: {
                    Text("Off")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
                .background(connectivity.isOn ? Color.gray.opacity(0.35) : Color.red)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
