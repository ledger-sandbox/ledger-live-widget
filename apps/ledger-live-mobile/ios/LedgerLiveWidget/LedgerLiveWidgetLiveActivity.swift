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
          let validated = context.state.blocksValidated ?? 0

          VStack {
            // Utilisation de l'opérateur ternaire
            HStack(spacing: 4) {
              Text(validated >= 10 ? "Your transaction has been validated!" : "Your transaction is being validated")
                .font(.caption)
                .foregroundColor(validated >= 10 ? .green : .white) // Texte vert si validé

              Image(systemName: validated >= 10 ? "checkmark.seal" : "gear")
                .symbolEffect(.rotate.clockwise.wholeSymbol, options: .repeating)
                .foregroundColor(validated >= 10 ? .green : .white)
            }

            // Affichage du ProgressView et du texte de validation si < 10

            VStack(alignment: .leading, spacing: 4) {
              ProgressView(value: Double(validated), total: 10)
                .tint(validated >= 10 ?.green : Color(red: 187 / 255, green: 176 / 255, blue: 255 / 255))
                .padding(.bottom, 2)

              Text("\(validated) / 10 blocks validated")
                .font(.caption2)
                .foregroundColor(validated >= 10 ? .green : .white.opacity(0.7))
            }
            .padding(8)
          }
        }
      }

      compactLeading: {
        Image(context.attributes.crypto).resizable().frame(width: 24, height: 24)
      } compactTrailing: {
        let validated = context.state.blocksValidated ?? 0
        ProgressView(
          value: Double(context.state.blocksValidated ?? 0),
          total: 10
        ) {
          Text(String(validated ?? 0))
            .font(.caption)
            .foregroundColor(.white)
        }
        .progressViewStyle(.circular)
        .tint(validated >= 10 ? Color.green : Color(red: 187 / 255, green: 176 / 255, blue: 255 / 255))

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
