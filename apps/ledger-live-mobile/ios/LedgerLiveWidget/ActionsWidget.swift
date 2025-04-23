//
//  ActionsWidget.swift
//  ledgerlivemobile
//
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

import Foundation
import SafariServices
import SwiftUI
import SwiftUICore
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
        ZStack {
            Color.black
            VStack {
                headerView()
                actionLinksView()
            }
        }
    }

    // MARK: - Header View

    private func headerView() -> some View {
        HStack {
            Image("Image")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(14)
            Spacer()
        }
    }

    // MARK: - Action Links View

    private func actionLinksView() -> some View {
        GeometryReader { geometry in
            let totalSpacing: CGFloat = 16 * 2
            let interItemSpacing: CGFloat = 12 * 2
            let itemWidth = (geometry.size.width - totalSpacing - interItemSpacing) / 3

            HStack(spacing: 12) {
                actionLink(title: NSLocalizedString("SEND", comment: "Send action"), url: "ledgerlive://send", iconName: "paperplane.fill", width: itemWidth)
                actionLink(title: NSLocalizedString("BUY", comment: "Buy action"), url: "ledgerlive://buy", iconName: "plus.circle.fill", width: itemWidth)
                actionLink(title: NSLocalizedString("SWAP", comment: "Swap action"), url: "ledgerlive://swap", iconName: "arrow.2.circlepath", width: itemWidth)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 80)
    }

    // MARK: - Action Link

    private func actionLink(title: String, url: String, iconName: String, width: CGFloat) -> some View {
        Link(destination: URL(string: url)!) {
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .cornerRadius(8)
                VStack {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
            }
            .frame(width: width, height: 64)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 1.5)
            )
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
