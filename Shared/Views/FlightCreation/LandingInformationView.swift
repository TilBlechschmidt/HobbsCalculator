//
//  LandingInformationView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

struct LandingInformationView: View {
    let route: RouteInformation
    let timePerTrafficPatternCircuit = 2 * 60

    @State var originLandings: Int = 0
    @State var intermediateLandings: [Int]
    @State var destinationLandings: Int = 1

    var landingInformation: LandingInformation {
        LandingInformation(origin: originLandings, intermediates: intermediateLandings, destination: destinationLandings, timePerTrafficPatternCircuit: timePerTrafficPatternCircuit)
    }

    var originPatternTime: Int {
        originLandings * timePerTrafficPatternCircuit
    }

    var intermediatePatternTime: Int {
        intermediateLandings.reduce(0) { $0 + $1 - 1 } * timePerTrafficPatternCircuit
    }

    var destinationPatternTime: Int {
        (destinationLandings - 1) * timePerTrafficPatternCircuit
    }

    var timeOvercommit: Bool {
        let minimumCrossCountryTime = route.legs.count * CrossCountryInformationView.minimumDurationPerLeg
        let flightTime = route.flightTime
        let patternTime = originPatternTime + intermediatePatternTime + destinationPatternTime
        let remainingTime = Int(round(flightTime)) - patternTime

        return remainingTime <= minimumCrossCountryTime
    }

    init(_ route: RouteInformation) {
        self.route = route
        self.intermediateLandings = route.waypoints.map { _ in 1 }
    }

    var body: some View {
        VStack {
            if timeOvercommit {
                Text("Too much time allocated to traffic patterns, nothing would be left for cross-country travel!")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }

            List {
                Section {
                    StepperRow(value: $originLandings, range: 0...Int.max, icon: "airplane.departure", label: route.origin, unit: "x")
                } header: {
                    Text("Origin")
                } footer: {
                    Text("\(originPatternTime / 60) min allotted for traffic circuits")
                }

                if !route.waypoints.isEmpty {
                    Section {
                        ForEach(route.waypoints.indices, id: \.self) { index in
                            StepperRow(value: $intermediateLandings[index], range: 1...Int.max, icon: "mappin.and.ellipse", label: route.waypoints[index], unit: "x")
                        }
                    } header: {
                        Text("Intermediate airports")
                    } footer: {
                        Text("\(intermediatePatternTime / 60) min allotted for traffic circuits")
                    }
                }

                Section {
                    StepperRow(value: $destinationLandings, range: 1...Int.max, icon: "airplane.arrival", label: route.destination, unit: "x")
                } header: {
                    Text("Destination")
                } footer: {
                    Text("\(destinationPatternTime / 60) min allotted for traffic circuits")
                }
            }.listStyle(.insetGrouped)
        }
            .navigationTitle("Landings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink("Next") {
                        CrossCountryInformationView(route, landingInformation)
                    }.disabled(timeOvercommit)
                }
            }
    }
}

struct LandingInformationView_Previews: PreviewProvider {
    static let flight = RouteInformation(
        startupTime: 46800.0,
        startupHobbs: 29160000.0,
        origin: "EDDH",
        waypoints: ["EDXQ"],
        destination: "EDDH",
        shutdownTime: 52200.0,
        shutdownHobbs: 29164080.0)

    static var previews: some View {
        NavigationView {
            LandingInformationView(flight)
        }
    }
}
