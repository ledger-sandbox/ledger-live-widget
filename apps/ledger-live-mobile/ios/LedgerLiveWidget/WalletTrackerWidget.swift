import WidgetKit
import AppIntents
import SwiftUI

struct WalletEntry: TimelineEntry {
    let date: Date
    let price: String
    let percentage: Double
    let isPriceHidden: Bool
}

struct WalletProvider: TimelineProvider {
    func placeholder(in context: Context) -> WalletEntry {
        WalletEntry(date: Date(), price: "$17,400.00", percentage: 3.2, isPriceHidden: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (WalletEntry) -> ()) {
        let entry = WalletEntry(date: Date(), price: "$17,400.00", percentage: 3.2, isPriceHidden: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WalletEntry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.ledgerlive.wallet")
        let price = defaults?.string(forKey: "walletPrice") ?? "$0.00"
        let percentage = defaults?.double(forKey: "walletPercentage") ?? 0.0
        let isHidden = defaults?.bool(forKey: "isPriceHidden") ?? false
        print("Widget lit price: \(price), percentage: \(percentage), hidden: \(isHidden)")
        let entry = WalletEntry(date: Date(), price: price, percentage: percentage, isPriceHidden: isHidden)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct PriceVisibilityManager {
    static let suiteName = "group.com.ledgerlive.wallet"
    static let key = "isPriceHidden"

    static func getVisibility() -> Bool {
        let defaults = UserDefaults(suiteName: suiteName)
        return defaults?.bool(forKey: key) ?? false
    }

    static func toggleVisibility() -> Bool {
        let current = getVisibility()
        let newValue = !current
        let defaults = UserDefaults(suiteName: suiteName)
        defaults?.set(newValue, forKey: key)
        return newValue
    }
}

struct TogglePriceVisibilityIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Price Visibility"
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let isHidden = PriceVisibilityManager.toggleVisibility()
        WidgetCenter.shared.reloadAllTimelines()
        return .result(value: isHidden)
    }
}

struct WalletWidgetEntryView : View {
    var entry: WalletEntry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color(.systemBackground))

            VStack(spacing: 0) {
                HStack {
                    Text("WALLET")
                        .font(.caption)
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    Spacer()

                    Image(colorScheme == .dark ? "Image" : "Image2")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                Spacer()

                VStack(spacing: 4) {
                    Text(entry.isPriceHidden ? "***" : entry.price)
                        .font(.title2)
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    Text(String(format: "%.2f%%", entry.percentage * 100))
                        .font(.footnote)
                        .foregroundColor(entry.percentage < 0 ? .red : .green)

                    Button(intent: TogglePriceVisibilityIntent()) {
                        Image(systemName: entry.isPriceHidden ? "eye.slash" : "eye")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct WalletWidget: Widget {
    let kind: String = "WalletWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WalletProvider()) { entry in
            WalletWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Wallet Tracker")
        .description("Shows current wallet price and evolution.")
        .supportedFamilies([.systemSmall])
    }
}
