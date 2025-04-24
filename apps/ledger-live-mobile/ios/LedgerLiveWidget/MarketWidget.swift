//
//  MarketWidget.swift
//  MarketWidget
//
//  Created by Lucas WEREY on 23/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import WidgetKit
import SwiftUI
import LineChartView
import Charts

struct ApiData: Decodable {
  var TIMESTAMP: Int
  var HIGH: Double
}

struct Data: Identifiable {
  var id: UUID = UUID()
  var TIMESTAMP: Int
  var HIGH: Double
}

struct ApiResponse: Decodable {
  let Data: [ApiData]
}

struct Provider: AppIntentTimelineProvider {
  func buildRequest(crypto: String, currency: String) -> URLRequest {
    print("calling \(crypto)-\(currency)")
    let urlComponents = URLComponents(string: "https://data-api.coindesk.com/spot/v1/historical/days?market=kraken&instrument=\(crypto)-\(currency)&limit=7&aggregate=1&fill=true&apply_mapping=true&response_format=JSON")!
    var request = URLRequest(url: urlComponents.url!)
    request.httpMethod = "GET"
    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
    request.setValue("8c49896ac6cf01659a5cbd8169a1ee15a2c0a8bedc225ff2262b57bb8b137790", forHTTPHeaderField: "Authorization")
    return request
  }
  
  func timeline(for configuration: SelectCryptoCurrencyIntent, in context: Context) async -> Timeline<SimpleEntry> {
    var crypto = "BTC"
    if configuration.cryptoDetail != nil {
      crypto = configuration.cryptoDetail!.id
    }
    
    var currency = "USD"
    if configuration.currencyDetail != nil {
      currency = configuration.currencyDetail!.id
    }
    
    let request = buildRequest(crypto: crypto, currency: currency)
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
      print(decodedResponse)
      let entry = SimpleEntry(date: Date(), data: decodedResponse.Data.map { data in Data(TIMESTAMP: data.TIMESTAMP, HIGH: data.HIGH)})
      return Timeline(entries: [entry], policy: .atEnd)
    } catch {
      print("fail \(error)")
    }
    
    return Timeline(entries: [], policy: .atEnd)
  }
  
    func placeholder(in context: Context) -> SimpleEntry {
      SimpleEntry(date: Date(), data: [])
    }

    func snapshot(for configuration: SelectCryptoCurrencyIntent, in context: Context) async -> SimpleEntry {
      SimpleEntry(date: Date(), data: [])
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let data: [Data]
}

func calculateOverallPercentageIncrease(values: [Double]) -> Double? {
    guard let firstValue = values.first, let lastValue = values.last, firstValue != 0 else {
        return nil // Return nil if the array is empty or the first value is zero
    }

    let increase = ((lastValue - firstValue) / firstValue) * 100
    return increase
}

struct MarketWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry

    var body: some View {
      Grid {
        if (entry.data == nil || entry.data.isEmpty) {
          Text("Loading data...")
        } else {
          VStack(spacing: 0) {
            GridRow {
              HStack {
                Spacer()
                Text(String(format: "$%.2f", entry.data[6].HIGH))
                  .bold()
                  .foregroundStyle(.white)
                  .gridColumnAlignment(.trailing)
                  .font(.system(size: 36))
              }
              .padding(.bottom, 0)
            }
            .frame(maxWidth: .infinity)
            
            GridRow {
              let percent = calculateOverallPercentageIncrease(values: entry.data.map { $0.HIGH })
              HStack {
                Spacer()
                Image("IncreaseIcon")
                  .renderingMode(.template)
                  .imageScale(.medium)
                  .gridColumnAlignment(.trailing)
                  .foregroundColor(.green)
                Text("\(String(format: "%.2f", percent!))%")
                  .bold()
                  .foregroundStyle(.green)
                  .gridColumnAlignment(.trailing)
                  .font(.system(size: 24))
              }
              .padding(.top, 0)
            }
            .frame(maxWidth: .infinity)
          }
          
          if (widgetFamily == .systemLarge) {
            GridRow {
              HStack {
                
                Spacer()
                  let linearGradient = LinearGradient(
                      gradient: Gradient(colors: [Color.green.opacity(0.4), Color.green.opacity(0)]),
                      startPoint: .top,
                      endPoint: .bottom
                  )
                

                  Chart {
                      ForEach(Array(entry.data.enumerated()), id: \.offset) { index, data in
                          LineMark(x: .value("Year", index),
                                   y: .value("Population", data.HIGH))
                              .foregroundStyle(Color.green)
                              .lineStyle(StrokeStyle(lineWidth: 5, lineCap: .round))
                      }

                      ForEach(Array(entry.data.enumerated()), id: \.offset) { index, data in
                          AreaMark(x: .value("Year", index),
                                   y: .value("Population", data.HIGH))
                      }
                      .interpolationMethod(.cardinal)
                      .foregroundStyle(linearGradient)
                  }
                  .chartLegend(.hidden)
                  .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
              }
            }
            .frame(maxWidth: .infinity, alignment: .center) // Ensure the GridRow takes full width
          }
          
          GridRow {
            HStack {
              Text("BTC")
                .bold()
                .foregroundStyle(.gray)
                .gridColumnAlignment(.leading)
              
              Spacer()
              
              Image("GearIcon")
                .renderingMode(.original)
                .imageScale(.medium)
                .gridColumnAlignment(.trailing)
              
              Image("LedgerLogo")
                .renderingMode(.template)
                .foregroundColor(.gray)
                .imageScale(.medium)
                .gridColumnAlignment(.trailing)
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .padding(0)
    }
}

struct MarketWidget: Widget {
    let kind: String = "MarketWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectCryptoCurrencyIntent.self, provider: Provider()) { entry in
            MarketWidgetEntryView(entry: entry)
            .containerBackground(Color("WidgetBackground"), for: .widget)
        }
    }
}

extension SelectCryptoCurrencyIntent {
  fileprivate static var crypto: SelectCryptoCurrencyIntent {
      let intent = SelectCryptoCurrencyIntent()
      intent.crypto = "BTC"
      intent.currency = "USD"
      return intent
  }
}

#Preview(as: .systemSmall) {
    MarketWidget()
} timeline: {
    SimpleEntry(date: .now, data: [])
    SimpleEntry(date: .now, data: [])
}
