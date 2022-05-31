//
//  FlightManager.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import Foundation

class FlightManager: ObservableObject {
    let persistenceManager: PersistenceManager?

    @Published var error: PersistenceError? = nil
    @Published var creationInProgress = false
    @Published var flights: [PersistedFlightInformation] = [
//        FlightInformation(route: HobbsCalculator.RouteInformation(startupTime: 27840.0, startupHobbs: 20059980.0, origin: "EDXQ", waypoints: [], destination: "EDXQ", shutdownTime: 31500.0, shutdownHobbs: 20062140.0), landing: HobbsCalculator.LandingInformation(origin: HobbsCalculator.LandingInformation.LandingCount(count: 0, time: 0.0), intermediates: [], destination: HobbsCalculator.LandingInformation.LandingCount(count: 8, time: 1680.0)), crossCountry: HobbsCalculator.CrossCountryInformation(durations: [480.0]), taxi: HobbsCalculator.TaxiInformation(origin: 900.0, intermediates: [], destination: 600.0))

//        FlightInformation(route: HobbsCalculator.RouteInformation(startupTime: 43320.0, startupHobbs: 20050320.0, origin: "EDXQ", waypoints: [], destination: "EDXQ", shutdownTime: 46500.0, shutdownHobbs: 20052960.0), landing: HobbsCalculator.LandingInformation(origin: HobbsCalculator.LandingInformation.LandingCount(count: 0, time: 0.0), intermediates: [], destination: HobbsCalculator.LandingInformation.LandingCount(count: 7, time: 1440.0)), crossCountry: HobbsCalculator.CrossCountryInformation(durations: [1200.0]), taxi: HobbsCalculator.TaxiInformation(origin: 300.0, intermediates: [], destination: 240.0))
//        FlightInformation(
//            route: HobbsCalculator.RouteInformation(
//                startupTime: 46800.0,
//                startupHobbs: 291600.0,
//                origin: "EDDH",
//                waypoints: ["EDXQ"],
//                destination: "EDDH",
//                shutdownTime: 57600.0,
//                shutdownHobbs: 299700.0),
//            landing: HobbsCalculator.LandingInformation(
//                origin: HobbsCalculator.LandingInformation.LandingCount(count: 0, time: 0.0),
//                intermediates: [HobbsCalculator.LandingInformation.LandingCount(count: 10, time: 2400.0)],
//                destination: HobbsCalculator.LandingInformation.LandingCount(count: 1, time: 0.0)),
//            crossCountry: HobbsCalculator.CrossCountryInformation(
//                durations: [2099.0, 3601.0]),
//            taxi: HobbsCalculator.TaxiInformation(
//                origin: 900.0,
//                intermediates: [900.0],
//                destination: 900.0))
    ]

    struct PersistenceError: Equatable, CustomStringConvertible {
        let title: String
        let description: String

        static var initFailure = PersistenceError(title: "Failed to initialize storage", description: "You may not be able to see past entries. The calculator itself will still work but the results will disappear once you close the app.")
    }

    init() {
        persistenceManager = PersistenceManager()

        if let persistence = persistenceManager, let flights = try? persistence.loadFlights() {
            print("Loaded \(flights.count) flight(s) from disk")
            self.flights.append(contentsOf: flights)
        } else {
            error = .initFailure
        }
    }

    func add(flight: FlightInformation) {
        if let persistence = persistenceManager {
            do {
                let persisted = try persistence.persist(flight: flight)
                flights.insert(persisted, at: 0)
            } catch {
                flights.insert(PersistedFlightInformation(flight), at: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.error = PersistenceError(title: "Failed to save flight", description: "You will be able to see the results but when you quit the app, they will be gone.\n\nReason: \(error)")
                }
            }
        } else {
            flights.insert(PersistedFlightInformation(flight), at: 0)
        }

        creationInProgress = false
    }

    func remove(at index: Int) {
        let element = self.flights.remove(at: index)

        if let persistence = persistenceManager {
            do {
                try persistence.deleteFlight(with: element.id)
            } catch {
                self.error = PersistenceError(title: "Failed to delete flight", description: "The flight might reappear when you restart the application.\n\nReason: \(error)")
            }
        }
    }

    func cancelCreation() {
        creationInProgress = false
    }
}
