//
//  FlightManager.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import Foundation

class FlightManager: ObservableObject {
    @Published var creationInProgress = false
    @Published var flights: [FlightInformation] = [
        FlightInformation(
            route: HobbsCalculator.RouteInformation(
                startupTime: 46800.0,
                startupHobbs: 291600.0,
                origin: "EDDH",
                waypoints: ["EDXQ"],
                destination: "EDDH",
                shutdownTime: 57600.0,
                shutdownHobbs: 299700.0),
            landing: HobbsCalculator.LandingInformation(
                origin: HobbsCalculator.LandingInformation.LandingCount(count: 0, time: 0.0),
                intermediates: [HobbsCalculator.LandingInformation.LandingCount(count: 10, time: 2400.0)],
                destination: HobbsCalculator.LandingInformation.LandingCount(count: 1, time: 0.0)),
            crossCountry: HobbsCalculator.CrossCountryInformation(
                durations: [2099.0, 3601.0]),
            taxi: HobbsCalculator.TaxiInformation(
                origin: 900.0,
                intermediates: [900.0],
                destination: 900.0))
    ]

    func add(flight: FlightInformation) {
        flights.append(flight)
        creationInProgress = false
    }

    func cancelCreation() {
        creationInProgress = false
    }
}
