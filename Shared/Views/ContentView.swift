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
    @StateObject var flightManager: FlightManager
    @StateObject var airportRegistry = AirportRegistry.default

    @State var errorPresented: Bool
    @State var showingTutorial = false

    let parser = TimeParser(allowInfiniteHours: true)

    init() {
        let flightManager = FlightManager()
        _flightManager = StateObject(wrappedValue: flightManager)
        _errorPresented = State(initialValue: flightManager.error != nil)
    }

    var body: some View {
        VStack {
            if flightManager.flights.isEmpty {
                VStack {
                    Spacer()
                    Text("Nothing here ✈️")
                        .foregroundColor(.secondary)
                        .padding(2)
                    Text("Get up in the air already!")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("How does this work?") { showingTutorial = true }
                        .padding()
                    Spacer()
                }
            } else {
                List {
                    ForEach(flightManager.flights, id: \.self) { flight in
                        NavigationLink {
                            LogbookEntryOverview(entries: flight.info.logbookEntries)
                                .navigationTitle("\(flight.info.route.origin) — \(flight.info.route.destination)")
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack {
                                VStack {
                                    HStack {
                                        Text(flight.info.route.origin)
                                        Spacer()
                                        Text("→")
                                        Spacer()
                                        Text(flight.info.route.destination)
                                    }.font(.body.monospaced())
                                    HStack {
                                        Text(parser.format(flight.info.route.startupTime))
                                        Spacer()
                                        Text(parser.format(flight.info.route.shutdownTime))
                                    }
                                        .foregroundColor(.secondary)
                                        .font(.caption.monospaced())
                                }
                                    .frame(minWidth: 10, idealWidth: 150, maxWidth: 200)
                                    .fixedSize()
                                Spacer()
                                VStack {
                                    Text(parser.format(flight.info.route.flightTime))
                                    Text(parser.format(flight.info.route.blockTime))
                                }
                                    .foregroundColor(.secondary)
                                    .font(.caption.monospaced())
                            }
                        }
                    }.onDelete(perform: deleteFlight(with:))
                }
            }

            HStack {
                Spacer()
                VerticallyLabelledValue(parser.format(flightManager.flights.reduce(0) { $0 + $1.info.route.blockTime}), label: "TBT")
                Spacer()
                VerticallyLabelledValue(parser.format(flightManager.flights.reduce(0) { $0 + $1.info.route.flightTime}), label: "TFT")
                Spacer()
                VerticallyLabelledValue(parser.format(flightManager.flights.reduce(0) { $0 + $1.info.route.taxiTime}), label: "TTT")
                Spacer()
            }
        }
            .navigationTitle("Flights")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingTutorial = true }) {
                        Image(systemName: "questionmark")
                    }
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
            .sheet(isPresented: $showingTutorial) {
                NavigationView {
                    TutorialView()
                        .navigationBarTitle("Tutorial")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button("Back") {
                                    showingTutorial = false
                                }
                            }
                        }
                }
            }
            .alert(flightManager.error?.title ?? "",
                isPresented: $errorPresented,
                actions: {
                    Button("OK", action: {
                        flightManager.error = nil
                    })
                }, message: {
                    Text(flightManager.error?.description ?? "Unknown error")
                }
            )
            .onChange(of: flightManager.error) { _ in
                errorPresented = flightManager.error != nil
            }
    }

    func deleteFlight(with indexSet: IndexSet) {
        indexSet.forEach { flightManager.remove(at: $0) }
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
