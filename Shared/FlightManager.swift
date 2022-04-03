//
//  FlightManager.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import Foundation

class FlightManager: ObservableObject {
    @Published var flights: [FlightInformation] = [
        FlightInformation(
            route: HobbsCalculator.RouteInformation(
                startupTime: 46800.0,
                startupHobbs: 46800.0,
                origin: "EDDH",
                waypoints: ["EDXQ"],
                destination: "EDDH",
                shutdownTime: 57600.0,
                shutdownHobbs: 54000.0),
            landing: HobbsCalculator.LandingInformation(
                origin: 5,
                intermediates: [10],
                destination: 5,
                timePerTrafficPatternCircuit: 120),
            crossCountry: HobbsCalculator.CrossCountryInformation(
                durations: [3423.0, 1617.0]),
            taxi: HobbsCalculator.TaxiInformation(
                origin: 2100.0,
                intermediates: [600.0],
                destination: 900.0))
    ]
    @Published var creationInProgress = false

    func add(flight: FlightInformation) {
        flights.append(flight)
        creationInProgress = false
    }

    func cancelCreation() {
        creationInProgress = false
    }
}
