//
//  CompactLogbookEntryView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import SwiftUI

struct CompactLogbookEntryView: View {
    let origin: String
    let destination: String

    let blockStart: String
    let blockEnd: String

    let departure: String
    let arrival: String

    let hobbsStart: String
    let hobbsEnd: String

    let landings: String

    init(entry: LogbookEntry) {
        let parser = TimeParser(allowInfiniteHours: true)

        self.origin = entry.origin
        self.destination = entry.destination

        self.blockStart = parser.format(entry.blockStart)
        self.blockEnd = parser.format(entry.blockEnd)

        self.departure = parser.format(entry.departure)
        self.arrival = parser.format(entry.arrival)

        self.hobbsStart = parser.format(entry.hobbsStart)
        self.hobbsEnd = parser.format(entry.hobbsEnd)

        self.landings = "\(entry.landings)"
    }

    init() {
        origin = "ORIG"
        destination = "DEST"

        blockStart = "OFBT"
        blockEnd = "ONBT"

        departure = "TOT"
        arrival = "TDT"

        hobbsStart = "HOBS"
        hobbsEnd = "HOBE"

        landings = "LDG#"
    }

    var body: some View {
        HStack {
            Group {
                Spacer()

                VStack {
                    Spacer()
                    Text(origin)
                    Spacer()
                    Text(destination)
                    Spacer()
                }

                divider

                VStack {
                    Spacer()
                    Text(blockStart)
                    Spacer()
                    Text(blockEnd)
                    Spacer()
                }

                divider

                VStack {
                    Spacer()
                    Text(departure)
                    Spacer()
                    Text(arrival)
                    Spacer()
                }
            }

            Group {
                divider

                VStack {
                    Spacer()
                    Text(hobbsStart)
                    Spacer()
                    Text(hobbsEnd)
                    Spacer()
                }

                divider

                VStack {
                    Spacer()
                    Text("-")
                        .opacity(0.25)
                    Spacer()
                    Text(landings)
                    Spacer()
                }

                Spacer()
            }
        }
            .font(.system(size: 15, weight: .light).monospaced())
            .overlay(Divider())
    }

    var divider: some View {
        Group {
            Spacer()
            Divider()
            Spacer()
        }
    }
}

struct CompactLogbookEntryView_Previews: PreviewProvider {
    static let entry = LogbookEntry(origin: "EDHE", destination: "EDXR", blockStart: 42360.0, departure: 42660.0, hobbsStart: 19738980.0, hobbsEnd: 19740540.0, arrival: 44220.0, blockEnd: 44640.0, landings: 6)

    static var previews: some View {
        CompactLogbookEntryView(entry: entry)
            .frame(maxHeight: 80)

        CompactLogbookEntryView()
            .frame(maxHeight: 80)
    }
}
