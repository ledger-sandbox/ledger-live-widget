//
//  LedgerLiveWidgetLiveActivity.swift
//  LedgerLiveWidget
//
//  Created by Lucas WEREY on 23/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct LedgerLiveWidgetAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    // Dynamic stateful properties about your activity go here!
    var startedAt: Date?
    var blocksValidated: Int?
    // This will be useful later on to calculate the bridge time (since the timer will be started from JS land)
    func getTimeIntervalSinceNow() -> Double {
      guard let startedAt = startedAt else {
        return 0
      }
      Task {
        print("Get time interval since now \(startedAt.timeIntervalSince1970 - Date().timeIntervalSince1970)")
      }
      return startedAt.timeIntervalSinceNow
    }
  }

  // Fixed non-changing properties about your activity go here!
  var tx: String
  var crypto: String
}

struct LedgerLiveWidgetLiveActivity: Widget {
  @State private var showGG = false // State to show "GG" when progress is completed
  @State private var previousValidated = -1

  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LedgerLiveWidgetAttributes.self) { context in
      // Lock screen/banner UI goes here
      VStack {
        Text(
          Date(timeIntervalSinceNow: context.state.getTimeIntervalSinceNow()),
          style: .timer
        )
        .font(.title)
        .fontWeight(.medium)
        .monospacedDigit()
      }
      .padding(10)
      .foregroundColor(.white)
      .activityBackgroundTint(Color.black)
      .activitySystemActionForegroundColor(Color.white)
    } dynamicIsland: { context in

      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image("Image")
            .resizable()
            .frame(width: 24, height: 24)
            .padding(8)
        }

        DynamicIslandExpandedRegion(.trailing) {
          Image(context.attributes.crypto)
            .resizable()
            .frame(width: 24, height: 24)
            .padding(8)
        }

        DynamicIslandExpandedRegion(.bottom) {
          if showGG {
            Text("GG Well Done")
              .font(.title)
              .foregroundColor(.green)
              .transition(.opacity)
              .padding(8)
          } else {
            Text("Tx in progress: \(context.attributes.tx)")
              .font(.caption)
              .foregroundColor(.white)

            Text("block: \(Double(context.state.blocksValidated ?? -1))")
              .font(.caption)
              .foregroundColor(.white)
            ProgressView(
              value: Double(context.state.blocksValidated ?? -1),
              total: 10
            )
            .tint(context.state.blocksValidated == 10 ? Color.green : Color(red: 187 / 255, green: 176 / 255, blue: 255 / 255))
            .padding(8)
          }
        }
      }

      compactLeading: {
        Image(context.attributes.crypto).resizable().frame(width: 24, height: 24)
      } compactTrailing: {
        ProgressView(
          value: Double(context.state.blocksValidated ?? -1),
          total: 10
        ) {
          Text(String(context.state.blocksValidated ?? -1))
            .font(.caption)
            .foregroundColor(.white)
        }
        .progressViewStyle(.circular)
        .tint(Color(red: 187 / 255, green: 176 / 255, blue: 255 / 255))

      } minimal: {
        Image(systemName: "timer")
          .imageScale(.medium)
          .foregroundColor(.white)
      }
      .widgetURL(URL(string: "https://etherscan.io/tx/\(context.attributes.tx)"))
      .keylineTint(Color.red)
    }
  }
}
