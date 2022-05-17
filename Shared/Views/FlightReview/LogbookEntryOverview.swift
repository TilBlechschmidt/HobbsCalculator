//
//  LogbookEntryOverview.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import SwiftUI

struct LogbookEntryOverview: View {
    let entries: [LogbookEntry]

    @State var decimalHobbs = false

    var body: some View {
        CompactLogbookEntryOverview(decimalHobbs: decimalHobbs, entries: entries)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { decimalHobbs.toggle() }, label: {
                        Image(systemName: decimalHobbs ? "clock" : "clock.fill")
                    })
                }
            }
    }
}

struct LogbookEntryOverview_Previews: PreviewProvider {
    static let entries = [
        LogbookEntry(origin: "EDDH", destination: "EDHE", blockStart: 39000.0, departure: 39360.0, hobbsStart: 19735980.0, hobbsEnd: 19738980.0, arrival: 42360.0, blockEnd: 42360.0, landings: 1),
        LogbookEntry(origin: "EDHE", destination: "EDXR", blockStart: 42360.0, departure: 42660.0, hobbsStart: 19738980.0, hobbsEnd: 19740540.0, arrival: 44220.0, blockEnd: 44640.0, landings: 6)
    ]

    static var previews: some View {
        NavigationView {
            LogbookEntryOverview(entries: entries)
                .navigationTitle("EDDH – EDXR")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
