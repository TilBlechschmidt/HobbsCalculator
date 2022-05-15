//
//  RouteInformationView.swift
//  HobbsCalculator (iOS)
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

struct FixedTime {
    var timestamp: Timestamp?
    var hobbs: HobbsValue?
}

struct Waypoint: Identifiable, Equatable {
    let id = UUID()
    var location = ""
}

struct RouteInformationView: View {
    @State var startup = FixedTime()
    @State var origin = "EDXQ"
    @State var waypoints: [Waypoint] = []
    @State var destination = "EDXQ"
    @State var shutdown = FixedTime()

    var inputsValid: Bool {
        guard let startupTime = startup.timestamp,
              let startupHobbs = startup.hobbs,
              let shutdownTime = shutdown.timestamp,
              let shutdownHobbs = shutdown.hobbs
        else {
            return false
        }

        let elapsedHobbs = shutdownHobbs - startupHobbs
        let elapsedTime = shutdownTime - startupTime

        return !origin.isEmpty &&
            waypoints.reduce(true) { $0 && !$1.location.isEmpty } &&
            !destination.isEmpty &&
            shutdownTime > startupTime &&
            shutdownHobbs > startupHobbs &&
            elapsedHobbs <= elapsedTime

        // TODO Add minimumTime & minimumHobbs checks
    }

    var flightInformation: RouteInformation? {
        guard let startupTime = startup.timestamp,
              let startupHobbs = startup.hobbs,
              let shutdownTime = shutdown.timestamp,
              let shutdownHobbs = shutdown.hobbs
        else {
            return nil
        }

        return RouteInformation(
            startupTime: startupTime,
            startupHobbs: startupHobbs,
            origin: origin,
            waypoints: waypoints.map { $0.location },
            destination: destination,
            shutdownTime: shutdownTime,
            shutdownHobbs: shutdownHobbs)
    }

    var body: some View {
        List {
            Section {
                LabelledValue(icon: "clock", label: "Time") {
                    TimeInput(value: $startup.timestamp)
                }

                LabelledValue(icon: "hourglass.bottomhalf.filled", label: "Hobbs") {
                    TimeInput(value: $startup.hobbs, parser: TimeParser(allowInfiniteHours: true))
                }
            } header: {
                Text("Startup")
            } footer: {
                Text("Data recorded at the moment the engine started")
            }

            Section {
                LabelledValue(icon: "airplane.departure", label: "Origin") {
                    LocationInput("EDDH", location: $origin).fixedSize()
                }

                ForEach($waypoints.animation()) { waypoint in
                    LabelledValue(icon: "mappin.and.ellipse", label: "Airport") {
                        LocationInput("EDXQ", location: waypoint.location)
                            .fixedSize()
                    }
                }.onDelete(perform: deleteWaypoint(with:))

                Button(action: { waypoints.append(Waypoint()) }) {
                    LabelledValue(icon: "plus", label: "Add waypoint") { Spacer() }
                }

                LabelledValue(icon: "airplane.arrival", label: "Destination") {
                    LocationInput("EDDH", location: $destination).fixedSize()
                }
            } header: {
                Text("Route")
            } footer: {
                Text("Origin, destination and intermediate airports where landings were performed without engine shutdown")
            }

            Section {
                LabelledValue(icon: "clock", label: "Time") {
                    TimeInput(value: $shutdown.timestamp)
                }

                LabelledValue(icon: "hourglass.tophalf.filled", label: "Hobbs") {
                    TimeInput(value: $shutdown.hobbs, parser: TimeParser(allowInfiniteHours: true))
                }
            } header: {
                Text("Shutdown")
            } footer: {
                Text("Data recorded at the moment the engine stopped")
            }
        }
            .listStyle(.insetGrouped)
            .animation(.default, value: waypoints)
            .navigationTitle("Flight information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink("Next") {
                        if let flightInformation = flightInformation {
                            LandingInformationView(flightInformation)
                        } else {
                            Text("Uh oh, something went wrong :(")
                        }
                    }.disabled(!inputsValid)
                }
            }
    }

    func deleteWaypoint(with indexSet: IndexSet) {
        indexSet.forEach { waypoints.remove(at: $0) }
    }
}

struct FlightCreationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RouteInformationView()
        }
    }
}
