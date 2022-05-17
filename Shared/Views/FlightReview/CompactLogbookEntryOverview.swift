//
//  CompactLogbookEntryOverview.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import SwiftUI

struct CompactLogbookEntryOverview: View {
    let decimalHobbs: Bool
    let parser = TimeParser(allowInfiniteHours: true)
    let entries: [LogbookEntry]

    var body: some View {
        List {
            ForEach(entries.indices, id: \.self) { index in
                Section {
                    CompactLogbookEntryView(entry: entries[index], decimalHobbs: decimalHobbs)
                        .frame(minHeight: 70)
                } header: {
                    Text("Leg #\(index + 1)")
                } footer: {
                    HStack {
                        Spacer()
                        VStack {
                            Text("flight \(parser.format(entries[index].flightTime))")
                            Text(" block \(parser.format(entries[index].blockTime))")
                        }.font(.caption.monospaced())
                    }
                }.headerProminence(.increased)
            }

            Section {
                CompactLogbookEntryView()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .foregroundColor(.secondary)
                    .frame(minHeight: 70)
            }
        }.listStyle(.grouped)
    }
}

struct CompactLogbookEntryOverview_Previews: PreviewProvider {
    static let entries = [
        LogbookEntry(origin: "EDDH", destination: "EDHE", blockStart: 39000.0, departure: 39360.0, hobbsStart: 19735980.0, hobbsEnd: 19738980.0, arrival: 42360.0, blockEnd: 42360.0, landings: 1),
        LogbookEntry(origin: "EDHE", destination: "EDXR", blockStart: 42360.0, departure: 42660.0, hobbsStart: 19738980.0, hobbsEnd: 19740540.0, arrival: 44220.0, blockEnd: 44640.0, landings: 6)
    ]

    static var previews: some View {
        CompactLogbookEntryOverview(decimalHobbs: false, entries: entries)
    }
}
