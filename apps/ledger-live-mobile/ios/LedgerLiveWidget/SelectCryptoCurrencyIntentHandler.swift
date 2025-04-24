//
//  SelectCryptoCurrencyIntentHandler.swift
//  ledgerlivemobile
//
//  Created by Moustafa KOTERBA on 24/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import Intents

class SelectCryptoCurrencyIntentHandler: NSObject {
    func resolveCryptoCurrency(for intent: SelectCryptoCurrencyIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
      completion(.success(with: intent.crypto))
    }

    func resolveMoneyCurrency(for intent: SelectCryptoCurrencyIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
      completion(.success(with: intent.currency))
    }
}
