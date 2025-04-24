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
  private var timer: DispatchSourceTimer? // Add this property to retain the Timer

  private func areActivitiesEnabled() -> Bool {
    return ActivityAuthorizationInfo().areActivitiesEnabled
  }

  @objc
  func startLiveActivity(_ tx: String, withCrypto crypto: String) -> Void {
    print("Starting with tx :", tx)
    print("Starting with crypto :", crypto)
    if (!areActivitiesEnabled()) {
      // User disabled Live Activities for the app, nothing to do
      return
    }
    // Preparing data for the Live Activity
    let activityAttributes = LedgerLiveWidgetAttributes(tx: tx, crypto: crypto)
    let contentState = LedgerLiveWidgetAttributes.ContentState(startedAt: Date())
    let activityContent = ActivityContent(state: contentState, staleDate:nil)
    do {
      print("Doing Activity")
      // Request to start a new Live Activity with the content defined above
      let activity = try Activity.request(attributes: activityAttributes, content:activityContent)
      self.fetchBlockNumber(tx: tx) { latestBlockNumber in
        self.fetchTransaction(tx: tx) { txBlockNumber in
          Task {
              print("Performing Task")
              print("latestBlockNumber : \(latestBlockNumber)")
              print("txBlockNumber : \(txBlockNumber)")
            await activity.update(using: LedgerLiveWidgetAttributes.ContentState(blocksValidated: (latestBlockNumber - txBlockNumber)))
          }
        }
      }
      let queue = DispatchQueue(label: "com.ledger.live.debug.LedgerLiveWidget", attributes: .concurrent)
      self.timer = DispatchSource.makeTimerSource(queue: queue)
      self.timer?.schedule(deadline: .now(), repeating: 5.0)
      self.timer?.setEventHandler { [weak self] in
        print("Timer ongoing")
        self?.fetchBlockNumber(tx: tx) { latestBlockNumber in
          self?.fetchTransaction(tx: tx) { txBlockNumber in
            Task {
                print("Performing Task")
                print("latestBlockNumber : \(latestBlockNumber)")
                print("txBlockNumber : \(txBlockNumber)")
              await activity.update(using: LedgerLiveWidgetAttributes.ContentState(blocksValidated: (latestBlockNumber - txBlockNumber)))
            }
          }
        }
      }
      self.timer?.resume()
    } catch {
      print("Error Starting Activity")
      // Handle errors, skipped for simplicity
    }
  }

  @objc
  func fetchBlockNumber(tx: String, completion: @escaping (Int) -> Void) {
    print("Fetching data with tx :", tx)
    let parameters = [
        "id": 1,
        "jsonrpc": "2.0",
        "method": "eth_blockNumber"
    ] as [String : Any?]

    
    do {
      let postDataBlockNumber = try JSONSerialization.data(withJSONObject: parameters, options: [])
      
      let url = URL(string: "https://eth-mainnet.g.alchemy.com/v2/vyXdALUMWU6nr5sYjdx1SDkscGGga75b")!
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.timeoutInterval = 10
      request.allHTTPHeaderFields = [
        "accept": "application/json",
        "content-type": "application/json"
      ]
      request.httpBody = postDataBlockNumber
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data, error == nil else {
              print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
              return
          }
          print("Data fetched: \(data)")
          let newData = String(data: data, encoding: .utf8) ?? "No Data"
          print("New data : \(newData)")
          if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
             let result = json["result"] as? String,
             let blockNumber = Int(result.dropFirst(2), radix: 16) {
             print("Block number")
             print(blockNumber)
             completion(blockNumber)
          }
        }
      task.resume()
      } catch {
        print("Error serializing JSON: \(error)")
      }
  }

  @objc
  func fetchTransaction(tx: String, completion: @escaping (Int) -> Void) {
    print("Fetching data with tx :", tx)
    let parameters = [
        "id": 1,
        "jsonrpc": "2.0",
        "method": "eth_getTransactionByHash",
        "params": [
            tx
        ]
    ] as [String : Any?]

    
    do {
      let postDataBlockNumber = try JSONSerialization.data(withJSONObject: parameters, options: [])
      
      let url = URL(string: "https://eth-mainnet.g.alchemy.com/v2/vyXdALUMWU6nr5sYjdx1SDkscGGga75b")!
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.timeoutInterval = 10
      request.allHTTPHeaderFields = [
        "accept": "application/json",
        "content-type": "application/json"
      ]
      request.httpBody = postDataBlockNumber
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data, error == nil else {
              print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
              return
          }
          print("Data fetched: \(data)")
          let newData = String(data: data, encoding: .utf8) ?? "No Data"
          print("New data : \(newData)")
          if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let result = json["result"] as? [String: Any], // Cast "result" to a dictionary
            let blockNumberHex = result["blockNumber"] as? String, // Access "blockNumber"
            let blockNumber = Int(blockNumberHex.dropFirst(2), radix: 16) {
            print("Block number")
            print(blockNumber)
            completion(blockNumber)
          }
        }
      task.resume()
      } catch {
        print("Error serializing JSON: \(error)")
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
