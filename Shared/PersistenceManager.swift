//
//  PersistenceManager.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 31.05.22.
//

import Foundation

struct PersistedFlightInformation: Hashable, Codable {
    let id: UUID
    let date: Date
    let info: FlightInformation

    init(_ info: FlightInformation) {
        id = UUID()
        date = Date.now
        self.info = info
    }
}

struct PersistenceManager {
    let fileManager = FileManager.default
    let documentDir: URL

    init?() {
        guard let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        self.documentDir = documentDir
    }

    func loadFlights() throws -> [PersistedFlightInformation] {
        let decoder = JSONDecoder()
        let files = try fileManager.contentsOfDirectory(at: documentDir, includingPropertiesForKeys: nil)

        var errors = 0
        var flights: [PersistedFlightInformation] = []

        for file in files {
            guard !file.hasDirectoryPath,
                  let data = fileManager.contents(atPath: file.path),
                  let flight = try? decoder.decode(PersistedFlightInformation.self, from: data)
            else {
                errors += 1
                continue
            }

            flights.append(flight)
        }

        if errors > 0 {
            print("Failed to load \(errors) flights")
        }

        return flights
    }

    func persist(flight: FlightInformation) throws -> PersistedFlightInformation {
        let persisted = PersistedFlightInformation(flight)
        let data = try JSONEncoder().encode(persisted)
        let url = documentDir.appendingPathComponent("\(persisted.id).json")

        guard fileManager.createFile(atPath: url.path, contents: data) else {
            throw Error.FailedToCreateFile
        }

        return persisted
    }

    func deleteFlight(with id: UUID) throws {
        let url = documentDir.appendingPathComponent("\(id).json")
        try fileManager.removeItem(at: url)
    }

    enum Error: Swift.Error {
        case FailedToCreateFile
    }
}
