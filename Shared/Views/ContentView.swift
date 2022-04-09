//
//  ContentView.swift
//  Shared
//
//  Created by Til Blechschmidt on 23.03.22.
//

import SwiftUI

struct LabelledValue<Child>: View where Child: View {
    let icon: String?
    let label: String
    let value: () -> Child

    init(icon: String?, label: String, value: @escaping () -> Child) {
        self.icon = icon
        self.label = label
        self.value = value
    }

    init(label: String, value: @escaping () -> Child) {
        self.init(icon: nil, label: label, value: value)
    }

    var body: some View {
        HStack {
            if let icon = icon {
                Label(label, systemImage: icon)
            } else {
                Text(label)
            }
            Spacer()
            self.value().foregroundColor(.secondary)
        }
    }
}

struct TripCalculatorView: View {
    @StateObject var flightManager = FlightManager()
    @StateObject var airportRegistry = AirportRegistry.default

    let parser = TimeParser(allowInfiniteHours: true)

    var body: some View {
        VStack {
            List {
                ForEach(flightManager.flights, id: \.self) { flight in
                    NavigationLink {
                        LogbookEntryOverview(entries: flight.logbookEntries)
                            .navigationTitle("\(flight.route.origin) — \(flight.route.destination)")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        HStack {
                            Text("\(flight.route.origin) — \(flight.route.destination)")
                            Spacer()
                            Text(parser.format(flight.route.blockTime)).foregroundColor(.secondary)
                        }
                    }
                }.onDelete(perform: deleteFlight(with:))
            }

            HStack {
                Spacer()
                VerticallyLabelledValue(parser.format(flightManager.flights.reduce(0) { $0 + $1.route.blockTime}), label: "TBT")
                Spacer()
                VerticallyLabelledValue(parser.format(flightManager.flights.reduce(0) { $0 + $1.route.flightTime}), label: "TFT")
                Spacer()
                VerticallyLabelledValue(parser.format(flightManager.flights.reduce(0) { $0 + $1.route.taxiTime}), label: "TTT")
                Spacer()
            }
        }
            .navigationTitle("Flights")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { flightManager.creationInProgress = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $flightManager.creationInProgress) {
                NavigationView {
                    RouteInformationView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    flightManager.cancelCreation()
                                }
                            }
                        }
                }
                    .environmentObject(flightManager)
                    .environmentObject(airportRegistry)
                    .interactiveDismissDisabled(true)
            }
    }

    func deleteFlight(with indexSet: IndexSet) {
        indexSet.forEach { flightManager.flights.remove(at: $0) }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            TripCalculatorView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
