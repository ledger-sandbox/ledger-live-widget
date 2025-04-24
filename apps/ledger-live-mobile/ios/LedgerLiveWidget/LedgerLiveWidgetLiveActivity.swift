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
      
      // This will be useful later on to calculate the bridge time (since the timer will be started from JS land)
      func getTimeIntervalSinceNow() -> Double {
        guard let startedAt = self.startedAt else {
          return 0
        }
        return startedAt.timeIntervalSince1970 - Date().timeIntervalSince1970
      }
      
      func getBlockNumber() async -> Int? {
        do {
            let parameters = [
                "id": 1,
                "jsonrpc": "2.0",
                "method": "eth_blockNumber"
            ] as [String : Any?]

            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])

            let url = URL(string: "https://eth-mainnet.g.alchemy.com/v2/docs-demo")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 10
            request.allHTTPHeaderFields = [
                "accept": "application/json",
                "content-type": "application/json"
            ]
            request.httpBody = postData

            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let result = json["result"] as? String,
               let blockNumber = Int(result.dropFirst(2), radix: 16) {
                print("Block number")
                print(blockNumber)
                return blockNumber
            }
        } catch {
          print("Error: \(error)")
        }
        return nil
      }
    }

    // Fixed non-changing properties about your activity go here!
    var tx: String
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
                    Text("Est")
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
                ProgressView(value: context.state.getTimeIntervalSinceNow(), total: 60) {
                    Text("\(context.state.getTimeIntervalSinceNow())")
                }.frame(width: 24, height: 24)
                .progressViewStyle(.circular)
                .tint(Color.white)
            } compactTrailing: {
              Text(
                Date(timeIntervalSinceNow: context.state.getTimeIntervalSinceNow()),
                style: .timer
              )
              .foregroundColor(.white)
              .frame(maxWidth: 32)
              .monospacedDigit()
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

extension LedgerLiveWidgetAttributes {
    fileprivate static var preview: LedgerLiveWidgetAttributes {
        LedgerLiveWidgetAttributes(tx: "0xa01f36240bfa7354e4d42ef09ba7512cb0145db54d46add111ad7eb38d7168c8")
    }
}

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
