//
//  LedgerLiveWidgetLiveActivity.swift
//  LedgerLiveWidget
//
//  Created by Lucas WEREY on 23/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LedgerLiveWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
      // Dynamic stateful properties about your activity go here!
      var startedAt: Date?
      var blocksValidated: Int?
      // This will be useful later on to calculate the bridge time (since the timer will be started from JS land)
      func getTimeIntervalSinceNow() -> Double {
        guard let startedAt = self.startedAt else {
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
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                  Image(context.attributes.crypto).resizable().frame(width: 24, height: 24)
                }
                DynamicIslandExpandedRegion(.trailing) {
                  Image(systemName: "progress.indicator").symbolEffect(.rotate, value: true)
                }
                DynamicIslandExpandedRegion(.bottom) {
                  Text("Tx: \(context.attributes.tx)")
                  Text(
                    Date(timeIntervalSinceNow: context.state.getTimeIntervalSinceNow()),
                      style: .timer
                  )
                    // more content
                }
            } compactLeading: {
              Image(context.attributes.crypto).resizable().frame(width: 24, height: 24)
            } compactTrailing: {
              Text(String(context.state.blocksValidated ?? -1))
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

//extension LedgerLiveWidgetAttributes {
//    fileprivate static var preview: LedgerLiveWidgetAttributes {
//        LedgerLiveWidgetAttributes(tx: "0xa01f36240bfa7354e4d42ef09ba7512cb0145db54d46add111ad7eb38d7168c8")
//    }
//}

//extension LedgerLiveWidgetAttributes.ContentState {
//    fileprivate static var smiley: LedgerLiveWidgetAttributes.ContentState {
//        LedgerLiveWidgetAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: LedgerLiveWidgetAttributes.ContentState {
//         LedgerLiveWidgetAttributes.ContentState(emoji: "🤩")
//     }
//}

//#Preview("Notification", as: .content, using: LedgerLiveWidgetAttributes.preview) {
//   LedgerLiveWidgetLiveActivity()
//} contentStates: {
//    LedgerLiveWidgetAttributes.ContentState.smiley
//    LedgerLiveWidgetAttributes.ContentState.starEyes
//}
