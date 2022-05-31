//
//  LandingInformationView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

struct OptionalLandingCount: Equatable {
    var count: Int
    var time: TimeInterval?

    var landingCount: LandingInformation.LandingCount {
        LandingInformation.LandingCount(count: self.count, time: self.time ?? 0)
    }
}

struct LandingInformationView: View {
    let parser = TimeParser(allowInfiniteHours: true)

    let route: RouteInformation
    let mergeOriginDestination: Bool

    static let defaultTimePerTrafficPatternCircuit: TimeInterval = 4*60

    @State var originLandings = OptionalLandingCount(count: 0, time: 0)
    @State var intermediateLandings: [OptionalLandingCount]
    @State var destinationLandings: OptionalLandingCount

    @State var simplified = true
    @State var timePerTrafficPatternCircuit: TimeInterval = defaultTimePerTrafficPatternCircuit

    @EnvironmentObject var airportRegistry: AirportRegistry

    var landingInformation: LandingInformation {
        assert(originLandings.count > 0 || originLandings.time == 0)
        assert(destinationLandings.count > 1 || destinationLandings.time == 0 || mergeOriginDestination)
        for landing in intermediateLandings {
            assert(landing.count > 1 || landing.time == 0)
        }

        return LandingInformation(origin: originLandings.landingCount,
                                  intermediates: intermediateLandings.map { $0.landingCount },
                                  destination: destinationLandings.landingCount)
    }

    var patternTime: TimeInterval {
        (originLandings.time ?? 0) + intermediateLandings.reduce(0) { $0 + ($1.time ?? 0) } + (destinationLandings.time ?? 0)
    }

    var remainingTime: TimeInterval {
        route.flightTime - patternTime
    }

    var timeOvercommit: Bool {
        let minimumCrossCountryTime = mergeOriginDestination ? 0.0 : TimeInterval(route.legs.count * CrossCountryInformationView.minimumDurationPerLeg)
        return remainingTime < minimumCrossCountryTime
    }

    var inputsValid: Bool {
        (originLandings.count > 0 || originLandings.time == 0)
        && intermediateLandings.reduce(true) { $0 && ($1.count > 1 || $1.time == 0)}
        && (destinationLandings.count > 1 || destinationLandings.time == 0 || mergeOriginDestination)
        && originLandings.time != nil
        && intermediateLandings.reduce(true) { $0 && $1.time != nil }
        && destinationLandings.time != nil
        && !timeOvercommit
    }

    init(_ route: RouteInformation) {
        self.route = route
        self.intermediateLandings = route.waypoints.map { _ in OptionalLandingCount(count: 1, time: 0) }
        self.mergeOriginDestination = route.waypoints.count == 0 && route.origin == route.destination

        if mergeOriginDestination {
            destinationLandings = OptionalLandingCount(count: 1, time: route.flightTime)
        } else {
            destinationLandings = OptionalLandingCount(count: 1, time: 0)
        }
    }

    var body: some View {
        VStack {
            if !mergeOriginDestination {
                Picker("Options", selection: Binding.init(get: { simplified ? 0 : 1 }, set: { simplified = $0 == 0 })) {
                    Text("Simplified").tag(0)
                    Text("Detailed").tag(1)
                }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                if timeOvercommit {
                    Text("Too much time allocated to traffic patterns, nothing would be left for cross-country travel!")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
            }

            List {
                if !mergeOriginDestination {
                    Section {
                        if simplified {
                            StepperRow(value: $originLandings.count, range: 0...Int.max, icon: "airplane.departure", label: route.origin, unit: "x")
                        } else {
                            StepperRow(value: $originLandings.animation().count, range: 0...Int.max, icon: "number", label: "Landings", unit: "x")

                            if originLandings.count > 0 {
                                LabelledValue(icon: "stopwatch", label: "Traffic pattern time") {
                                    TimeInput(value: $originLandings.time)
                                }
                            }
                        }
                    } header: {
                        Text(simplified ? "Origin" : "\(route.origin) — Origin")
                    } footer: {
                        if simplified {
                            Text("\(Int((originLandings.time ?? 0) / 60)) min allotted for traffic circuits")
                        } else if originLandings.count > 0 {
                            Text("All landings should be considered as you normally depart without making circuits")
                        }
                    }
                }

                if !route.waypoints.isEmpty {
                    if simplified {
                        Section {
                            ForEach(route.waypoints.indices, id: \.self) { index in
                                StepperRow(value: $intermediateLandings[index].count, range: 1...Int.max, icon: "mappin.and.ellipse", label: route.waypoints[index], unit: "x")
                                    .onChange(of: intermediateLandings[index]) {
                                        updateIntermediateTime($0, index: index)
                                    }
                            }
                        } header: {
                            Text("Intermediate airports")
                        } footer: {
                            Text("\(Int(intermediateLandings.reduce(0) { $0 + ($1.time ?? 0) } / 60)) min allotted for traffic circuits")
                        }
                    } else {
                        ForEach(route.waypoints.indices, id: \.self) { index in
                            Section {
                                StepperRow(value: $intermediateLandings.animation()[index].count, range: 1...Int.max, icon: "number", label: "Landings", unit: "x")

                                if intermediateLandings[index].count > 1 {
                                    LabelledValue(icon: "stopwatch", label: "Traffic pattern time") {
                                        TimeInput(value: $intermediateLandings[index].time)
                                    }
                                }
                            } header: {
                                Text("\(route.waypoints[index])")
                            } footer: {
                                if intermediateLandings[index].count > 1 {
                                    Text("First landing is considered part of cross-country time and should not be included in time")
                                }
                            }
                        }
                    }
                }

                Section {
                    if simplified {
                        StepperRow(value: $destinationLandings.count, range: 1...Int.max, icon: "airplane.arrival", label: route.destination, unit: "x")
                    } else {
                        StepperRow(value: $destinationLandings.animation().count, range: 1...Int.max, icon: "number", label: "Landings", unit: "x")

                        if destinationLandings.count > 1 {
                            LabelledValue(icon: "stopwatch", label: "Traffic pattern time") {
                                TimeInput(value: $destinationLandings.time)
                            }
                        }
                    }
                } header: {
                    if !mergeOriginDestination {
                        Text(simplified ? "Destination" : "\(route.destination) — Destination")
                    }
                } footer: {
                    if simplified && !mergeOriginDestination {
                        Text("\(Int((destinationLandings.time ?? 0) / 60)) min allotted for traffic circuits")
                    } else if destinationLandings.count > 1 && !mergeOriginDestination {
                        Text("First landing is considered part of cross-country time and should not be included in time")
                    }
                }
            }.listStyle(.insetGrouped)

            if !mergeOriginDestination {
                HStack {
                    Spacer()
                    VerticallyLabelledValue(parser.format(patternTime), label: "TP")
                    Spacer()
                    VerticallyLabelledValue(parser.format(remainingTime), label: "XC")
                    Spacer()
                }.padding(.bottom, 8)
            }
        }
            .animation(.default, value: simplified)
            .onChange(of: originLandings, perform: updateOriginTime)
            .onChange(of: destinationLandings, perform: updateDestinationTime)
            .navigationTitle("Landings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink("Next") {
                        // Because the view makes assertions which would crash, we only instantiate it conditionally
                        if inputsValid {
                            CrossCountryInformationView(route, landingInformation, airportRegistry)
                        }
                    }.disabled(!inputsValid)
                }
            }
    }

    func updateOriginTime(_ value: OptionalLandingCount) {
        if simplified {
            originLandings.time = Double(originLandings.count) * timePerTrafficPatternCircuit
        } else if originLandings.count == 0 {
            originLandings.time = 0
        }
    }

    func updateIntermediateTime(_ value: OptionalLandingCount, index: Int) {
        if simplified {
            intermediateLandings[index].time = Double(intermediateLandings[index].count - 1) * timePerTrafficPatternCircuit
        } else if intermediateLandings[index].count == 1 {
            intermediateLandings[index].time = 0
        }
    }

    func updateDestinationTime(_ value: OptionalLandingCount) {
        if mergeOriginDestination {
            destinationLandings.time = route.flightTime
        } else if simplified {
            destinationLandings.time = Double(destinationLandings.count - 1) * timePerTrafficPatternCircuit
        } else if destinationLandings.count == 1 {
            destinationLandings.time = 0
        }
    }
}

struct LandingInformationView_Previews: PreviewProvider {
    static let flight = RouteInformation(
        startupTime: 46800.0,
        startupHobbs: 29160000.0,
        origin: "EDDH",
        waypoints: ["EDXQ", "EDHE"],
        destination: "EDDH",
        shutdownTime: 52200.0,
        shutdownHobbs: 29164080.0)

    static var previews: some View {
        NavigationView {
            LandingInformationView(flight)
        }.environmentObject(AirportRegistry.default)
    }
}
