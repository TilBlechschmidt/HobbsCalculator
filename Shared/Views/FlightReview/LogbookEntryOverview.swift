//
//  LogbookEntryOverview.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import SwiftUI

struct LogbookEntryOverview: View {
    let entries: [LogbookEntry]

    @State var displayChoice = 0

    var body: some View {
        Group {
            if displayChoice == 1 {
                SparseLogbookEntryOverview(entries: entries)
                    .transition(
                        .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                    )
            } else {
                CompactLogbookEntryOverview(entries: entries)
                    .transition(
                        .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
                    )
            }
        }
            .animation(.default, value: displayChoice)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Picker("Options", selection: $displayChoice.animation()) {
                        Text("Compact").tag(0)
                        Text("Detailed").tag(1)
                    }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
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
