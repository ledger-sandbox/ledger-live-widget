//
//  WalletWidgetModule.swift
//  ledgerlivemobile
//
//  Created by Robin VINCENT on 24/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import Foundation
import WidgetKit
import React

@objc(WalletWidgetModule)
class WalletWidgetModule: NSObject {
  
  @objc(updateWalletData:percentage:resolver:rejecter:)
  func updateWalletData(price: String, percentage: Double, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
    let defaults = UserDefaults(suiteName: "group.com.ledgerlive.wallet")
    defaults?.set(price, forKey: "walletPrice")
    defaults?.set(percentage, forKey: "walletPercentage")
    print("Écriture faite ✅")

    WidgetCenter.shared.reloadAllTimelines()

    resolver(true)
  }
}
