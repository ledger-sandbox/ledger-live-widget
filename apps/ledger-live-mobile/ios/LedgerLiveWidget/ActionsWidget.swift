//  ActionsWidget.swift
//  ledgerlivemobile
//
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct ActionsWidgetEntry: TimelineEntry {
    let date: Date
}

// MARK: - Timeline Provider

struct ActionsWidgetProvider: TimelineProvider {
    func placeholder(in _: Context) -> ActionsWidgetEntry {
        ActionsWidgetEntry(date: Date())
    }

    func getSnapshot(in _: Context, completion: @escaping (ActionsWidgetEntry) -> Void) {
        completion(ActionsWidgetEntry(date: Date()))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<ActionsWidgetEntry>) -> Void) {
        let timeline = Timeline(entries: [ActionsWidgetEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}

// MARK: - Widget Entry View

struct ActionsWidgetEntryView: View {
    var entry: ActionsWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Image("Image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)

                Text("Quick Actions")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding(.bottom, 4)

            Spacer() // Add a spacer to push the CTAs row down

            HStack(spacing: 20) { // Increase spacing between buttons
                actionLink(title: "SEND", url: "ledgerlive://send", iconName: "paperplane.fill")
                actionLink(title: "BUY", url: "ledgerlive://buy", iconName: "plus.circle.fill")
                actionLink(title: "SWAP", url: "ledgerlive://swap", iconName: "arrow.2.circlepath")
            }
            .padding(.horizontal, 16) // Add horizontal padding for additional spacing

            Spacer() // Add a spacer to push the CTAs row up
        }
        .padding()
        .background(Color.black.opacity(0.6))
    }

    private func actionLink(title: String, url: String, iconName: String) -> some View {
        Link(destination: URL(string: url)!) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1.5)
                        )

                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                }

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Widget Configuration

struct ActionsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ActionsWidget", provider: ActionsWidgetProvider()) { entry in
            ActionsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Wallet Quick Actions")
        .description("Perform quick wallet actions: Send, Buy, Swap.")
        .supportedFamilies([.systemMedium])
        .disableContentMarginsIfNeeded()
    }
}
