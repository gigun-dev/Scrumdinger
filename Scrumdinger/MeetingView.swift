//
//  ContentView.swift
//  Scrumdinger
//
//  Created by Fukuto Morita on 2026/06/03.
//

import SwiftUI

struct MeetingView: View {
    var body: some View {
        VStack{
            ProgressView(value:10, total:15)
            HStack{
                VStack(alignment: .leading) {
                    Text("経過時間")
                        .font(.caption)
                    Label("300", systemImage: "hourglass.tophalf.fill")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("残り時間")
                        .font(.caption)
                    Label("600", systemImage: "hourglass.bottomhalf.fill")
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Time remaining")
            .accessibilityValue("10 minutes")
            Circle()
                .strokeBorder(lineWidth: 24)
            HStack {
                Text("Spearker 1 of 3")
                Spacer()
                Button(action:{}) {
                    Image(systemName: "forward.fill")
                }
            }
            .accessibilityLabel("Next speaker")
        }
        .padding()
    }
}

#Preview {
    MeetingView()
}
