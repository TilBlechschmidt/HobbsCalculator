//
//  OldFlightInformation.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 27.03.22.
//

import Foundation

typealias HobbsValue = TimeInterval
typealias LocationIdentifier = String
typealias Timestamp = TimeInterval

struct StartupInformation {
    let location: LocationIdentifier
    let timestamp: Timestamp
    let hobbs: HobbsValue
}

struct DepartureInformation {
    let location: LocationIdentifier
    let hobbs: HobbsValue
    let landings: Int
}

struct ShutdownInformation {
    let location: LocationIdentifier
    let timestamp: Timestamp
    let hobbs: HobbsValue
    let landings: Int
}

struct Leg {
    let origin: LocationIdentifier
    let destination: LocationIdentifier

    let blockStart: Timestamp
    let departure: Timestamp
    let hobbsStart: HobbsValue
    let hobbsEnd: HobbsValue
    let arrival: Timestamp
    let blockEnd: Timestamp

    let landings: Int
}

struct Flight: Identifiable {
    let id = UUID()

    let origin: LocationIdentifier
    let destination: LocationIdentifier

    let legs: [Leg]
}

struct OldFlightInformation {
    let startup: StartupInformation
    let departures: [DepartureInformation]
    let shutdown: ShutdownInformation

    var blockTime: TimeInterval {
        shutdown.timestamp - startup.timestamp
    }

    var flightTime: TimeInterval {
        shutdown.hobbs - startup.hobbs
    }

    var taxiTime: TimeInterval {
        blockTime - flightTime
    }

    func buildLegs(startupTaxi: TimeInterval, intermediateTaxiTimes: [TimeInterval], shutdownTaxi: TimeInterval) -> Flight {
        assert(intermediateTaxiTimes.count == departures.count)

        struct TimeTracker {
            private(set) var wallTime: Timestamp
            private(set) var hobbsTime: Timestamp

            mutating func add(taxi: TimeInterval) -> Timestamp {
                wallTime += taxi
                return wallTime
            }

            mutating func add(flight: TimeInterval) -> Timestamp {
                wallTime += flight
                hobbsTime += flight
                return wallTime
            }

            mutating func advance(to hobbs: TimeInterval) -> Timestamp {
                let delta = hobbs - hobbsTime
                hobbsTime = hobbs
                wallTime += delta
                return hobbsTime
            }
        }

        var legs: [Leg] = []
        var tracker = TimeTracker(wallTime: startup.timestamp, hobbsTime: startup.hobbs)

        legs.append(
            Leg(origin: startup.location,
                destination: departures.first?.location ?? shutdown.location,
                blockStart: tracker.wallTime,
                departure: tracker.add(taxi: startupTaxi),
                hobbsStart: tracker.hobbsTime,
                hobbsEnd: tracker.advance(to: departures.first?.hobbs ?? shutdown.hobbs),
                arrival: tracker.wallTime,
                blockEnd: departures.isEmpty ? tracker.add(taxi: shutdownTaxi) : tracker.wallTime,
                landings: departures.first?.landings ?? shutdown.landings)
        )

        for i in 0..<departures.count {
            let departure = departures[i]
            let nextLocation = i + 1 < departures.count ? departures[i + 1].location : shutdown.location
            let nextHobbs = i + 1 < departures.count ? departures[i + 1].hobbs : shutdown.hobbs
            let nextTaxi = i + 1 < departures.count ? 0.0 : shutdownTaxi
            let nextLandings = i + 1 < departures.count ? departures[i + 1].landings : shutdown.landings

            legs.append(
                Leg(origin: departure.location,
                    destination: nextLocation,
                    blockStart: tracker.wallTime,
                    departure: tracker.add(taxi: intermediateTaxiTimes[i]),
                    hobbsStart: tracker.hobbsTime,
                    hobbsEnd: tracker.advance(to: nextHobbs),
                    arrival: tracker.wallTime,
                    blockEnd: tracker.add(taxi: nextTaxi),
                    landings: nextLandings)
            )
        }

        return Flight(origin: startup.location, destination: shutdown.location, legs: legs)
    }
}
