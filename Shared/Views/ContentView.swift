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

//struct InputSummaryView: View {
//    var body: some View {
//            List {
//                Section("Startup") {
//                    LabelledValue(icon: "location.fill", label: "Location", value: "EDDH")
//                    LabelledValue(icon: "clock", label: "Time", value: "13:26Z")
//                    LabelledValue(icon: "hourglass", label: "Hobbs", value: "1861:32")
//                }
//
//                Section("Intermediate airport") {
//                    LabelledValue(icon: "location.fill", label: "Location", value: "EDHE")
//                    LabelledValue(icon: "airplane.arrival", label: "Landings", value: "5")
//                    LabelledValue(icon: "hourglass", label: "Hobbs (departure)", value: "1861:59")
//                }
//
//                Section("Shutdown") {
//                    LabelledValue(icon: "location.fill", label: "Location", value: "EDDH")
//                    LabelledValue(icon: "clock", label: "Time", value: "14:26Z")
//                    LabelledValue(icon: "hourglass", label: "Hobbs", value: "1862:10")
//                }
//            }
//                .listStyle(.insetGrouped)
//                .navigationTitle("Summary")
//    }
//}

//struct MenuItem: Identifiable {
//    var id = UUID()
//    var icon: String?
//    var label: String
//    var value: String
//    var subMenuItems: [MenuItem]?
//}

//struct OutputView: View {
//    let menuItems1 = [
//        MenuItem(label: "Origin", value: "EDDH", subMenuItems: [
//            MenuItem(icon: "clock", label: "Startup", value: "14:24Z"),
//            MenuItem(icon: "airplane.departure", label: "Takeoff", value: "14:26Z"),
//            MenuItem(icon: "hourglass.bottomhalf.filled", label: "Hobbs", value: "1861:32"),
//        ]),
//        MenuItem(label: "Destination", value: "EDHE", subMenuItems: [
//            MenuItem(icon: "hourglass.tophalf.filled", label: "Hobbs", value: "1862:28"),
//            MenuItem(icon: "airplane.arrival", label: "Landing", value: "14:26Z"),
//            MenuItem(icon: "clock", label: "Shutdown", value: "15:32Z"),
//        ])
//    ]
//
//    let menuItems2 = [
//        MenuItem(label: "Origin", value: "EDHE", subMenuItems: [
//            MenuItem(icon: "clock", label: "Startup", value: "15:32Z"),
//            MenuItem(icon: "airplane.departure", label: "Takeoff", value: "15:35Z"),
//            MenuItem(icon: "hourglass.bottomhalf.filled", label: "Hobbs", value: "1862:28"),
//        ]),
//        MenuItem(label: "Destination", value: "EDDH", subMenuItems: [
//            MenuItem(icon: "hourglass.tophalf.filled", label: "Hobbs", value: "1863:39"),
//            MenuItem(icon: "airplane.arrival", label: "Landing", value: "16:45Z"),
//            MenuItem(icon: "clock", label: "Shutdown", value: "16:55Z"),
//        ])
//    ]
//
//    let index: Int
//
//    var body: some View {
//        List {
//            Section("Leg #1") {
//                OutlineGroup(menuItems1, children: \.subMenuItems) { item in
//                    LabelledValue(icon: item.icon, label: item.label) { Text(item.value) }
//                }
//            }
//
//            Section("Leg #2") {
//                OutlineGroup(menuItems2, children: \.subMenuItems) { item in
//                    LabelledValue(icon: item.icon, label: item.label) { Text(item.value) }
//                }
//            }
//        }
//            .listStyle(.insetGrouped)
//            .navigationTitle("Flight #\(index)")
//    }
//}

//struct OldTripCalculatorView: View {
//    @State var flights: [Flight]
//    @State var flightCreationInProgress = false
//
//    var latestLeg: Leg? {
//        guard let flight = flights.last, let leg = flight.legs.last else { return nil }
//        return leg
//    }
//
//    var body: some View {
//        List(flights) { flight in
//            NavigationLink("\(flight.origin) — \(flight.destination)") {
//                LegOverview(legs: flight.legs)
//                    .navigationTitle("\(flight.origin) — \(flight.destination)")
//            }
//        }
//            .navigationTitle("Trip overview")
//            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    Button("Add flight") {
//                        flightCreationInProgress = true
//                    }
//                }
//            }
//            .sheet(isPresented: $flightCreationInProgress) {
//                NavigationView {
//                    FlightQuestionnaire(lastHobbs: latestLeg?.hobbsEnd, lastLocation: latestLeg?.destination, onSubmit: {
//                        flights.append($0)
//                        flightCreationInProgress = false
//                    })
//                        .navigationTitle("New flight")
//                        .navigationBarTitleDisplayMode(.inline)
//                        .toolbar {
//                            ToolbarItemGroup(placement: .navigationBarLeading) {
//                                Button("Cancel") {
//                                    flightCreationInProgress = false
//                                }
//                            }
//                        }
//                }
//            }
//    }
//}

struct TripCalculatorView: View {
    @StateObject var flightManager = FlightManager()

    var body: some View {
        List(flightManager.flights, id: \.self) { flight in
            NavigationLink("\(flight.route.origin) — \(flight.route.destination)") {
                LegOverview(legs: flight.logbookEntries)
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
                }.environmentObject(flightManager)
            }
    }
}

struct ContentView: View {
//    @State var flightCreationInProgress = false

    static let flight = RouteInformation(
        startupTime: 46800.0,
        startupHobbs: 29160000.0,
        origin: "EDDH",
        waypoints: ["EDXQ"],
        destination: "EDDH",
        shutdownTime: 52200.0,
        shutdownHobbs: 29164080.0)

    static let landing = LandingInformation(origin: 0,
        intermediates: [6],
        destination: 1,
        timePerTrafficPatternCircuit: 120)

    var body: some View {
        NavigationView {
            // TripCalculatorView(flights: [])
            TripCalculatorView()

//            CrossCountryInformationView(ContentView.flight, ContentView.landing)
        }
//        let flight = OldFlightInformation(
//            startup: StartupInformation(location: "EDDH", timestamp: 39000.0, hobbs: 19735980.0),
//            departures: [
//                DepartureInformation(location: "EDHE", hobbs: 19738980.0, landings: 1)
//            ],
//            shutdown: ShutdownInformation(location: "EDXR", timestamp: 44640.0, hobbs: 19740540.0, landings: 6)
//        )
//
//        TimeDistributionView(flight: flight) { _ in }

//        VStack {
//            Button("Create flight", action: { flightCreationInProgress = true })
//                .sheet(isPresented: $flightCreationInProgress) {
//                    NavigationView {
//                        FlightQuestionnaire(lastHobbs: nil, lastLocation: nil) {
//                            print("SUBMITTED \($0)")
//                            flightCreationInProgress = false
//                        }
//                            .navigationTitle("New flight")
//                            .navigationBarTitleDisplayMode(.inline)
//                            .toolbar {
//                                ToolbarItemGroup(placement: .navigationBarLeading) {
//                                    Button("Cancel") {
//                                        flightCreationInProgress = false
//                                    }
//                                }
//                            }
//                    }
//                }
//        }

//        NavigationView {
//            List {
//                FlightBuilderView()
//
//                Section("Input summary") {
//                    NavigationLink("EDDH – EDHE") {
//                        InputSummaryView()
//                    }
//                    NavigationLink("EDHE – EDDH") {
//                        InputSummaryView()
//                    }
//                }
//                Section("Calculated data") {
//                    NavigationLink("Flight #1", destination: {
//                        OutputView(index: 1)
//                    })
//                    NavigationLink("Flight #2", destination: {
//                        OutputView(index: 1)
//                    })
//                }
//            }
//                .navigationTitle("Trip calculation")
////                .navigationBarTitleDisplayMode(.inline)
//            OutputView(index: 1)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
