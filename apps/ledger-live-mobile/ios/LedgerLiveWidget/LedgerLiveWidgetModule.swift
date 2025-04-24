//
//  LedgerLiveWidgetModule.swift
//  ledgerlivemobile
//
//  Created by Come GRELLARD on 23/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import Foundation
import ActivityKit

@objc(LedgerLiveWidgetModule)
class LedgerLiveWidgetModule: NSObject {

  private func areActivitiesEnabled() -> Bool {
    return ActivityAuthorizationInfo().areActivitiesEnabled
  }

  @objc
  func startLiveActivity(_ tx: String) -> Void {
    print("Starting with tx :", tx)
    if (!areActivitiesEnabled()) {
      // User disabled Live Activities for the app, nothing to do
      return
    }
    // Preparing data for the Live Activity
    let activityAttributes = LedgerLiveWidgetAttributes(tx: tx)
    let contentState = LedgerLiveWidgetAttributes.ContentState(startedAt: Date())
    let activityContent = ActivityContent(state: contentState, staleDate:nil)
    do {
      print("Doing Activity")
      // Request to start a new Live Activity with the content defined above
      try Activity.request(attributes: activityAttributes, content:activityContent)
    } catch {
      print("Error Starting Activity")
      // Handle errors, skipped for simplicity
    }
  }

  @objc
  func stopLiveActivity() -> Void {
    // A task is a unit of work that can run concurrently in a lightweight thread, managed by the Swift runtime
    // It helps to avoid blocking the main thread
    Task {
      for activity in Activity<LedgerLiveWidgetAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }
}
