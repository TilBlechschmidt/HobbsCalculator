//
//  TaxiInformationView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

struct TaxiInformationView: View {
    let parser = TimeParser(allowInfiniteHours: false)

    let route: RouteInformation
    let landing: LandingInformation
    let crossCountry: CrossCountryInformation
    let taxiTime: Int

    @State var origin: Int
    @State var intermediates: [Int]
    @State var destination: Int
    @EnvironmentObject var flightManager: FlightManager

    var remaining: Int {
        taxiTime - origin - destination - intermediates.reduce(0) { $0 + $1 }
    }

    var taxiInformation: TaxiInformation {
        TaxiInformation(
            origin: TimeInterval(origin * 60),
            intermediates: intermediates.map { TimeInterval($0 * 60) },
            destination: TimeInterval(destination * 60))
    }

    init(_ route: RouteInformation, _ landing: LandingInformation, _ crossCountry: CrossCountryInformation) {
        self.route = route
        self.landing = landing
        self.crossCountry = crossCountry
        self.taxiTime = Int(round(route.taxiTime) / 60)

        let (initial, remainder) = taxiTime.quotientAndRemainder(dividingBy: route.waypoints.count + 2)

        self.origin = initial + remainder
        self.intermediates = route.waypoints.map { _ in initial }
        self.destination = initial
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VerticallyLabelledValue(parser.format(route.blockTime), label: "Block")
                Spacer()
                VerticallyLabelledValue(parser.format(route.flightTime), label: "Flight")
                Spacer()
                VerticallyLabelledValue(parser.format(route.taxiTime), label: "Taxi")
                Spacer()

                VerticallyLabelledValue(parser.format(TimeInterval(remaining * 60)), label: "Remaining")
                    .foregroundColor(remaining >= 0 ? (remaining == 0 ? .green : .orange) : .red)
                Spacer()
            }

            List {
                Section("\(route.origin) — Origin") {
                    TimeStepperRow(value: $origin, range: 0...taxiTime, icon: "airplane.departure", label: "Departure")
                }

                ForEach(intermediates.indices, id: \.self) { index in
                    Section(
                        content: {
                            TimeStepperRow(value: $intermediates[index], range: 0...taxiTime, icon: "tortoise.fill", label: "Backtaxi")
                        },
                        header: {
                            Text("\(route.waypoints[index]) — Intermediate #1")
                        },
                        footer: {
                            Text("Taxi time during full-stop landings (e.g. backtaxi)")
                        }
                    )
                }

                Section("\(route.destination) — Destination") {
                    TimeStepperRow(value: $destination, range: 0...taxiTime, icon: "airplane.arrival", label: "Arrival")
                }
            }
        }
            .listStyle(.insetGrouped)
            .navigationTitle("Taxi time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Finish") {
                        flightManager.add(flight: FlightInformation(
                            route: route,
                            landing: landing,
                            crossCountry: crossCountry,
                            taxi: taxiInformation))
                    }
                }
            }
    }
}

struct TaxiInformationView_Previews: PreviewProvider {
    static let flight = RouteInformation(
        startupTime: 46800.0,
        startupHobbs: 29160000.0,
        origin: "EDDH",
        waypoints: ["EDXQ"],
        destination: "EDDH",
        shutdownTime: 52200.0,
        shutdownHobbs: 29164080.0)

    static let landing = LandingInformation(
        origin: LandingInformation.LandingCount(count: 0, time: 0),
        intermediates: [LandingInformation.LandingCount(count: 6, time: 10)],
        destination: LandingInformation.LandingCount(count: 1, time: 0))

    static let crossCountry = CrossCountryInformation(durations: [2040, 2040])

    static var previews: some View {
        NavigationView {
            TaxiInformationView(flight, landing, crossCountry)
        }
    }
}
