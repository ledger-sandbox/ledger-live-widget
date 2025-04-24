//
//  SelectCryptoCurrencyIntent.swift
//  ledgerlivemobile
//
//  Created by Moustafa KOTERBA on 24/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

//
//  AppIntent.swift
//  LedgerLiveWidget
//
//  Created by Lucas WEREY on 23/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import WidgetKit
import AppIntents

struct CurrencyQuery: EntityQuery {
    func entities(for identifiers: [CurrencyDetail.ID]) async throws -> [CurrencyDetail] {
      CurrencyDetail.allCurrencies.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [CurrencyDetail] {
      CurrencyDetail.allCurrencies
    }
    
    func defaultResult() async -> CurrencyDetail? {
        try? await suggestedEntities().first
    }
}

struct CurrencyDetail: AppEntity {
    let id: String
    let imageName: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "CurrencyDetail"
    static var defaultQuery = CurrencyQuery()

    var displayRepresentation: DisplayRepresentation {
      DisplayRepresentation(title: .init(stringLiteral: id), image: .init(named: imageName))
    }

    static let allCurrencies: [CurrencyDetail] = [
      CurrencyDetail(id: "USD", imageName: "bitcoin"),
      CurrencyDetail(id: "EUR", imageName: "ethereum"),
    ]
}

struct CryptoQuery: EntityQuery {
    func entities(for identifiers: [CryptoDetail.ID]) async throws -> [CryptoDetail] {
      CryptoDetail.allCryptos.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [CryptoDetail] {
      CryptoDetail.allCryptos
    }
    
    func defaultResult() async -> CryptoDetail? {
        try? await suggestedEntities().first
    }
}

struct CryptoDetail: AppEntity {
    let id: String
    let imageName: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Cryptocurrency"
    static var defaultQuery = CryptoQuery()

    var displayRepresentation: DisplayRepresentation {
      DisplayRepresentation(title: .init(stringLiteral: id), image: .init(named: imageName))
    }

    static let allCryptos: [CryptoDetail] = [
        CryptoDetail(id: "BTC", imageName: "bitcoin"),
        CryptoDetail(id: "ETH", imageName: "ethereum"),
        CryptoDetail(id: "USDT", imageName: "tether"),
        CryptoDetail(id: "XRP", imageName: "ripple"),
        CryptoDetail(id: "BNB", imageName: "binance"),
        CryptoDetail(id: "SOL", imageName: "solana"),
        CryptoDetail(id: "USDC", imageName: "usd-coin")
    ]
}

struct SelectCryptoCurrencyIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Crypto", default: "BTC")
    var crypto: String
  
    @Parameter(title: "Currency", default: "USD")
    var currency: String
  
    @Parameter(title: "Crypto")
    var cryptoDetail: CryptoDetail?
  
    @Parameter(title: "Currency")
    var currencyDetail: CurrencyDetail?
}
