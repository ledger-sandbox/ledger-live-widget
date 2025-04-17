import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    // Cache the latest fetched rows
    private static var latestRows: [RowData] = []

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), rows: Self.latestRows.isEmpty ? defaultSampleRows() : Self.latestRows)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), rows: Self.latestRows.isEmpty ? defaultSampleRows() : Self.latestRows)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        var entries: [SimpleEntry] = []

        // Fetch top 5 cryptocurrencies
        let rows = await fetchTopCryptocurrencies()
        Self.latestRows = rows // Cache the latest rows

        // Create a timeline entry
        let entry = SimpleEntry(date: currentDate, rows: rows)
        entries.append(entry)

        // Refresh the widget every hour
        return Timeline(entries: entries, policy: .after(currentDate.addingTimeInterval(60 * 60)))
    }

    private func defaultSampleRows() -> [RowData] {
        return [
            RowData(title: "Bitcoin", value: "$27,000", deepLink: "ledgerlive://swap", iconURL: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400"),
            RowData(title: "Ethereum", value: "$1,800", deepLink: "ledgerlive://swap", iconURL: "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628"),
            RowData(title: "Tether", value: "$1.00", deepLink: "ledgerlive://swap", iconURL: ""),
            RowData(title: "BNB", value: "$300", deepLink: "ledgerlive://swap", iconURL: ""),
            RowData(title: "XRP", value: "$0.50", deepLink: "ledgerlive://swap", iconURL: ""),
        ]
    }

    private func fetchTopCryptocurrencies() async -> [RowData] {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=5&page=1")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode([CryptoData].self, from: data)
            print(decodedResponse)
            return decodedResponse.map { crypto in
                RowData(
                    title: crypto.symbol,
                    value: "$\(String(format: "%.2f", crypto.current_price))",
                    deepLink: "ledgerlive://swap",
                    iconURL: crypto.image
                )
            }
        } catch {
            print("Error fetching cryptocurrencies: \(error)")
            return defaultSampleRows() // Fallback to default sample data
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let rows: [RowData]
}

struct RowData {
    let title: String
    let value: String
    let deepLink: String
    let iconURL: String
}

struct CryptoData: Codable {
    let symbol: String
    let current_price: Double
    let image: String
}

struct LL_WidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                // Cryptocurrency rows
                ForEach(entry.rows.indices, id: \.self) { index in
                    Link(destination: URL(string: entry.rows[index].deepLink)!) {
                        HStack {
                            // Coin Icon
                            AsyncImage(url: URL(string: entry.rows[index].iconURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                            }

                            // Coin Name and Value
                            Text(entry.rows[index].title)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(entry.rows[index].value)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct LL_Widget: Widget {
    let kind: String = "LL_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            LL_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview(as: .systemSmall) {
    LL_Widget()
} timeline: {
    SimpleEntry(date: .now, rows: [
        RowData(title: "Bitcoin", value: "$27,000", deepLink: "ledgerlive://swap", iconURL: ""),
        RowData(title: "Ethereum", value: "$1,800", deepLink: "ledgerlive://swap", iconURL: ""),
        RowData(title: "Tether", value: "$1.00", deepLink: "ledgerlive://swap", iconURL: ""),
        RowData(title: "BNB", value: "$300", deepLink: "ledgerlive://swap", iconURL: ""),
        RowData(title: "XRP", value: "$0.50", deepLink: "ledgerlive://swap", iconURL: ""),
    ])
}
