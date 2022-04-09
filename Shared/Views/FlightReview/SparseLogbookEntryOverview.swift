//
//  SparseLogbookEntryOverview.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 27.03.22.
//

import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String?
    let label: String
    let value: String
    let subMenuItems: [MenuItem]?
}

struct MenuItemList: Identifiable {
    let id = UUID()
    let index: Int
    let menuItems: [MenuItem]
}

struct SparseLogbookEntryOverview: View {
    let items: [MenuItemList]

    init(entries: [LogbookEntry]) {
        items = entries.enumerated().map {
            SparseLogbookEntryOverview.buildMenuItems(from: $0.element, with: $0.offset + 1)
        }
    }

    var body: some View {
        List {
            ForEach(items) { list in
                Section("Leg #\(list.index)") {
                    OutlineGroup(list.menuItems, children: \.subMenuItems) { item in
                        LabelledValue(icon: item.icon, label: item.label) { Text(item.value) }
                    }
                }
            }
        }.listStyle(.insetGrouped)
    }

    static let parser = TimeParser(allowInfiniteHours: true)

    static func buildMenuItems(from entry: LogbookEntry, with index: Int) -> MenuItemList {
        MenuItemList(index: index, menuItems: [
            MenuItem(icon: nil, label: "Origin", value: entry.origin, subMenuItems: [
                MenuItem(icon: "clock", label: "Block start", value: parser.format(entry.blockStart), subMenuItems: nil),
                MenuItem(icon: "airplane.departure", label: "Takeoff", value: parser.format(entry.departure), subMenuItems: nil),
                MenuItem(icon: "hourglass.bottomhalf.filled", label: "Hobbs", value: parser.format(entry.hobbsStart), subMenuItems: nil),
            ]),
            MenuItem(icon: nil, label: "Destination", value: entry.destination, subMenuItems: [
                MenuItem(icon: "hourglass.tophalf.filled", label: "Hobbs", value: parser.format(entry.hobbsEnd), subMenuItems: nil),
                MenuItem(icon: "airplane.arrival", label: "Landing", value: parser.format(entry.arrival), subMenuItems: nil),
                MenuItem(icon: "clock", label: "Block end", value: parser.format(entry.blockEnd), subMenuItems: nil),
            ]),
            MenuItem(icon: nil, label: "Landings", value: "\(entry.landings)", subMenuItems: nil)
        ])
    }
}

struct LegOverview_Previews: PreviewProvider {
    static let entries = [
        LogbookEntry(origin: "EDDH", destination: "EDHE", blockStart: 39000.0, departure: 39360.0, hobbsStart: 19735980.0, hobbsEnd: 19738980.0, arrival: 42360.0, blockEnd: 42360.0, landings: 1),
        LogbookEntry(origin: "EDHE", destination: "EDXR", blockStart: 42360.0, departure: 42660.0, hobbsStart: 19738980.0, hobbsEnd: 19740540.0, arrival: 44220.0, blockEnd: 44640.0, landings: 6)
    ]

    static var previews: some View {
        SparseLogbookEntryOverview(entries: entries)
    }
}
