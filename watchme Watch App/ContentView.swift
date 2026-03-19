//
//  ContentView.swift
//  watchme Watch App
//
//  Created by Ray Brennan on 19/03/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    
    var body: some View {
        VStack(spacing: 6) {
            Spacer()
            
            // Power icon with color feedback
            Image(systemName: connectivity.isOn ? "power.circle.fill" : "power.circle")
                .font(.system(size: 80, weight: .regular))
                .foregroundStyle(connectivity.isOn ? .green : .red)
  
            
            // Status text
            Text(connectivity.isOn ? "Power is ON" : "Power is OFF")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Last received event time (from phone)
            if let time = connectivity.lastEventTime {
                Text("Last change: \(time)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No events yet")
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            
         
            
            // On / Off buttons – full width for easy tapping on watch
            HStack(spacing: 12) {
                Button {
                    connectivity.sendPowerState(isOn: true)
                } label: {
                    Text("On")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button {
                    connectivity.sendPowerState(isOn: false)
                } label: {
                    Text("Off")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.horizontal, 16)
            
            Text("Synced with iPhone")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("Watch ContentView appeared – isOn: \(connectivity.isOn), last time: \(connectivity.lastEventTime ?? "none")")
        }
    }
}

#Preview {
    ContentView()
}
