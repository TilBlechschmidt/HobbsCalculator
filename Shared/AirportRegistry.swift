//
//  AirportRegistry.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 09.04.22.
//

import Foundation
import CoreLocation

struct Airport {
    let id: String
    let name: String
    let location: CLLocation

    init?(from csvRow: String) {
        let fields = csvRow.split(separator: ",")

        guard fields.count == 4, let lat = Double(fields[2]), let lng = Double(fields[3]) else {
            return nil
        }

        self.id = String(fields[0])
        self.name = String(fields[1])
        self.location = CLLocation(latitude: lat, longitude: lng)
    }
}

class AirportRegistry: ObservableObject {
    let airports: [String : Airport]

    static let `default`: AirportRegistry = {
        let url = Bundle.main.url(forResource: "airports", withExtension: ".csv")!
        let csv = try! String(contentsOf: url)
        return AirportRegistry(from: csv)
    }()

    init(from csv: String) {
        var airports: [String : Airport] = [:]

        csv.enumerateLines(invoking: { row, _ in
            if let airport = Airport(from: row) {
                // For some reason ~431 airports are duplicated 🤷‍♂️
                airports[airport.id] = airport
            } else {
                print("Failed to parse airport row! '\(row)'")
            }
        })

        print("Loaded \(airports.count) airports")

        self.airports = airports
    }

    func knowsAirport(identifiedBy identifier: String) -> Bool {
        airports[identifier] != nil
    }

    func fetchAirport(identifiedBy identifier: String) -> Airport? {
        airports[identifier]
    }
}
