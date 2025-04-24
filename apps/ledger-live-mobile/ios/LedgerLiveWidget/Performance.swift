//
//  Performance.swift
//  ledgerlivemobile
//
//  Created by Lucas WEREY on 23/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import WidgetKit
import SwiftUI
import Foundation

struct PerformanceProvider: TimelineProvider {
    let topMovers = [
      TopMoverAsset(currencyId: "bitcoin", symbol: "BTC", percentChange: 5.2, color: .orange, imageURL: ""),
      TopMoverAsset(currencyId: "ethereum", symbol: "ETH", percentChange: 3.8, color: .blue, imageURL: ""),
      TopMoverAsset(currencyId: "polkadot", symbol: "DOT", percentChange: 7.1, color: .pink, imageURL: ""),
      TopMoverAsset(currencyId: "cardano", symbol: "ADA", percentChange: -2.3, color: .teal, imageURL: ""),
    ]

    func placeholder(in context: Context) -> PerformanceEntry {
        PerformanceEntry(date: Date(), topMovers: topMovers)
    }

    func getSnapshot(in context: Context, completion: @escaping (PerformanceEntry) -> Void) {
        completion(PerformanceEntry(date: Date(), topMovers: topMovers))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PerformanceEntry>) -> Void) {
        LedgerAPI.fetchTopMovers { topMovers in
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let entry = PerformanceEntry(date: Date(), topMovers: topMovers)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}

struct TopMoverAsset: Identifiable {
  let currencyId: String
    let id = UUID()
    let symbol: String
    let percentChange: Double
    let color: Color
    let imageURL: String
}

struct PerformanceEntry: TimelineEntry {
    let date: Date
    let topMovers: [TopMoverAsset]
}

struct PerformanceWidgetEntryView: View {
    var entry: PerformanceProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Image("Image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)

                Text("Today's top movers")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding(.bottom, 8)

            HStack(spacing: 12) {
                ForEach(entry.topMovers) { asset in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .strokeBorder(Color.clear, lineWidth: 0)
                                .frame(width: 50, height: 50)

                            if let url = URL(string: asset.imageURL),
                               let imageData = try? Data(contentsOf: url),
                               let uiImage = UIImage(data: imageData) {
                                Link(destination: URL(string: "ledgerlive://market/\(asset.currencyId)")!) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 50, height: 50)
                                }
                            } else {
                                ProgressView()
                            }
                        }

                        Text(asset.symbol)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 4) {
                            Image(systemName: asset.percentChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .resizable()
                                .frame(width: 8, height: 8)
                                .foregroundColor(asset.percentChange >= 0 ? .green : .red)

                            Text(String(format: "%.1f%%", asset.percentChange))
                                .font(.system(size: 12))
                                .foregroundColor(asset.percentChange >= 0 ? .green : .red)
                        }

                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.6))
    }
}

struct PerformanceWidget: Widget {
    let kind: String = "PerformanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PerformanceProvider()) { entry in
            PerformanceWidgetEntryView(entry: entry)
                .widgetURL(URL(string: "ledgerlive://market"))
        }
        .configurationDisplayName("Top Movers")
        .description("Shows today's top movers in your portfolio.")
        .supportedFamilies([.systemMedium])
        .disableContentMarginsIfNeeded()
    }
}

struct LedgerAPI {
    static func fetchTopMovers(completion: @escaping ([TopMoverAsset]) -> Void) {
        guard let url = URL(string: "https://countervalues.live.ledger.com/v3/markets?to=USD&limit=4&top=50&sort=positive-price-change-1d&supported=true") else {
            print("Invalid URL")
            return
        }

        print("Fetching top movers...")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received from API")
                return
            }

            print("Raw API Response: \(String(data: data, encoding: .utf8) ?? "Invalid response")")

            do {
                let decoder = JSONDecoder()
                let coins = try decoder.decode([Coin].self, from: data)
                let topMovers = Array(coins.prefix(4)).map { coin in 
                    TopMoverAsset(
                        currencyId: coin.id,
                        symbol: coin.ticker.uppercased(),
                        percentChange: coin.priceChangePercentage24h ?? 0,
                        color: .random,
                        imageURL: coin.image
                    )
                }
                completion(topMovers)
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct Coin: Decodable {
    let id: String
    let ticker: String
    let priceChangePercentage24h: Double?
    let image: String
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}


