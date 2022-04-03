//
//  TimeDistributionView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 27.03.22.
//

import SwiftUI

struct VerticallyLabelledValue: View {
    let label: String
    let value: String

    init(_ value: String, label: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        VStack {
            Text(label).foregroundColor(.secondary)
            Text(value).bold()
        }
    }
}

struct TimeStepperRow: View {
    let value: Binding<Int>
    let range: ClosedRange<Int>
    let icon: String
    let label: String

    var body: some View {
        StepperRow(value: value, range: range, icon: icon, label: label, unit: "min")
    }
}

struct TimeDistributionView: View {
    let flight: OldFlightInformation
    let onSubmit: (Flight) -> ()
    let parser = TimeParser(allowInfiniteHours: true)

    @State var startupTaxiTime: Int = 0
    @State var intermediateTaxiTimes: [(DepartureInformation, Int)]
    @State var shutdownTaxiTime: Int = 0

    var maximum: Int {
        Int(ceil(flight.taxiTime / 60))
    }

    var assigned: Int {
        startupTaxiTime
        + intermediateTaxiTimes.reduce(0, { acc, value in acc + value.1 })
        + shutdownTaxiTime
    }

    var remaining: Int {
        maximum - assigned
    }

    init(flight: OldFlightInformation, onSubmit: @escaping (Flight) -> ()) {
        self.flight = flight
        self.onSubmit = onSubmit
        intermediateTaxiTimes = flight.departures.map { ($0, 0) }
    }

    var body: some View {
        VStack {
            Text("Taxi time distribution").font(.title).padding()
            HStack {
                Spacer()
                VerticallyLabelledValue(parser.format(flight.blockTime), label: "Block")
                Spacer()
                VerticallyLabelledValue(parser.format(flight.flightTime), label: "Flight")
                Spacer()
                VerticallyLabelledValue(parser.format(flight.taxiTime), label: "Taxi")
                Spacer()

                VerticallyLabelledValue(parser.format(TimeInterval(remaining * 60)), label: "Remaining")
                    .foregroundColor(remaining >= 0 ? (remaining == 0 ? .green : .orange) : .red)
                Spacer()
            }

            List {
                Section("\(flight.startup.location) — Origin") {
                    TimeStepperRow(value: $startupTaxiTime, range: 0...maximum, icon: "airplane.departure", label: "Departure")
                }

                ForEach($intermediateTaxiTimes, id: \.0.hobbs) { entry in
                    let departure = entry.0
                    let taxi = entry.1

                    Section(
                        content: {
                            TimeStepperRow(value: taxi, range: 0...maximum, icon: "tortoise.fill", label: "Backtaxi")
                        },
                        header: {
                            Text("\(departure.wrappedValue.location) — Intermediate #1")
                        },
                        footer: {
                            Text("Taxi time during full-stop landings (e.g. backtaxi)")
                        }
                    )
                }

                Section("\(flight.shutdown.location) — Destination") {
                    TimeStepperRow(value: $shutdownTaxiTime, range: 0...maximum, icon: "airplane.arrival", label: "Arrival")
                }

                Button("Submit", action: submit)
                    .disabled(remaining != 0)
            }
        }
    }

    func submit() {
        let startupTaxi = TimeInterval(startupTaxiTime * 60)
        let intermediateTaxiTimes = intermediateTaxiTimes.map { TimeInterval($0.1 * 60) }
        let shutdownTaxi = TimeInterval(shutdownTaxiTime * 60)
        let legs = flight.buildLegs(startupTaxi: startupTaxi, intermediateTaxiTimes: intermediateTaxiTimes, shutdownTaxi: shutdownTaxi)

        onSubmit(legs)
    }
}

struct TimeDistributionView_Previews: PreviewProvider {
    static let flight = OldFlightInformation(
        startup: StartupInformation(location: "EDDH", timestamp: 39000.0, hobbs: 19735980.0),
        departures: [
//            DepartureInformation(location: "EDHE", hobbs: 19738980.0, landings: 1)
        ],
        shutdown: ShutdownInformation(location: "EDXR", timestamp: 44640.0, hobbs: 19740540.0, landings: 6)
    )

    static var previews: some View {
        TimeDistributionView(flight: flight, onSubmit: { _ in })
    }
}
