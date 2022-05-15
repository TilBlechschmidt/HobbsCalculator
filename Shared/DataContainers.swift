//
//  DataContainers.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import Foundation

typealias HobbsValue = TimeInterval
typealias LocationIdentifier = String
typealias Timestamp = TimeInterval

struct LegInformation {
    let origin: LocationIdentifier
    let destination: LocationIdentifier
}

struct RouteInformation: Hashable {
    let startupTime: Timestamp
    let startupHobbs: HobbsValue

    let origin: LocationIdentifier
    let waypoints: [LocationIdentifier]
    let destination: LocationIdentifier

    let shutdownTime: Timestamp
    let shutdownHobbs: HobbsValue

    var flightTime: TimeInterval {
        shutdownHobbs - startupHobbs
    }

    var blockTime: TimeInterval {
        shutdownTime - startupTime
    }

    var taxiTime: TimeInterval {
        blockTime - flightTime
    }

    var legs: [LegInformation] {
        ([origin] + waypoints + [destination])
            .windows(of: 2)
            .map {
                LegInformation(origin: $0.first!, destination: $0.last!)
            }
    }
}

struct LandingInformation: Hashable {
    struct LandingCount: Hashable {
        var count: Int
        var time: TimeInterval
    }

    let origin: LandingCount
    let intermediates: [LandingCount]
    let destination: LandingCount

    var trafficPatternTime: TimeInterval {
        origin.time + intermediates.reduce(0) { $0 + $1.time } + destination.time
    }
}

extension LandingInformation.LandingCount: AdditiveArithmetic {
    static func - (lhs: LandingInformation.LandingCount, rhs: LandingInformation.LandingCount) -> LandingInformation.LandingCount {
        LandingInformation.LandingCount(count: lhs.count - rhs.count, time: lhs.time - rhs.time)
    }

    static func + (lhs: LandingInformation.LandingCount, rhs: LandingInformation.LandingCount) -> LandingInformation.LandingCount {
        LandingInformation.LandingCount(count: lhs.count + rhs.count, time: lhs.time + rhs.time)
    }

    static var zero: LandingInformation.LandingCount {
        LandingInformation.LandingCount(count: 0, time: 0.0)
    }
}

struct CrossCountryInformation: Hashable {
    let durations: [TimeInterval]
}

struct TaxiInformation: Hashable {
    let origin: TimeInterval
    let intermediates: [TimeInterval]
    let destination: TimeInterval
}

struct LogbookEntry {
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

struct FlightInformation: Hashable {
    let route: RouteInformation
    let landing: LandingInformation
    let crossCountry: CrossCountryInformation
    let taxi: TaxiInformation

    var logbookEntries: [LogbookEntry] {
        class Waypoint {
            let location: LocationIdentifier
            var landings: LandingInformation.LandingCount
            var taxiTime: TimeInterval

            internal init(location: LocationIdentifier, landings: LandingInformation.LandingCount, taxiTime: TimeInterval) {
                self.location = location
                self.landings = landings
                self.taxiTime = taxiTime
            }

            func extract(crossCountryLanding: Bool = false, consumeTaxiTime: Bool = true) -> ExtractedWaypoint {
                let landings: LandingInformation.LandingCount

                if crossCountryLanding {
                    landings = LandingInformation.LandingCount(count: 1, time: 0)
                    self.landings.count -= 1
                } else {
                    landings = self.landings
                    self.landings = LandingInformation.LandingCount(count: 0, time: 0)
                }

                let taxiTime: TimeInterval

                if consumeTaxiTime {
                    taxiTime = self.taxiTime
                    self.taxiTime = 0
                } else {
                    taxiTime = 0
                }

                return ExtractedWaypoint(location: location, landings: landings, taxiTime: taxiTime)
            }
        }

        struct ExtractedWaypoint {
            let location: LocationIdentifier
            let landings: LandingInformation.LandingCount
            let taxiTime: TimeInterval

            func merge(with other: ExtractedWaypoint) -> ExtractedWaypoint? {
                guard self.location == other.location else { return nil }
                return ExtractedWaypoint(location: self.location, landings: self.landings + other.landings, taxiTime: self.taxiTime + other.taxiTime)
            }
        }

        enum Leg {
            case CrossCountry(ExtractedWaypoint, TimeInterval, ExtractedWaypoint)
            case TrafficPatterns(ExtractedWaypoint, TimeInterval)

            var waypoint: ExtractedWaypoint {
                switch self {
                case .CrossCountry(let waypoint, _, _):
                    return waypoint
                case .TrafficPatterns(let waypoint, _):
                    return waypoint
                }
            }
        }

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
                return hobbsTime
            }

            mutating func advance(to hobbs: TimeInterval) -> Timestamp {
                let delta = hobbs - hobbsTime
                hobbsTime = hobbs
                wallTime += delta
                return hobbsTime
            }
        }

        // Aggregate all the data for each waypoint
        let origin = Waypoint(location: route.origin, landings: landing.origin, taxiTime: taxi.origin)
        let intermediates = zip(zip(route.waypoints, landing.intermediates), taxi.intermediates).map {
            Waypoint(location: $0.0.0, landings: $0.0.1, taxiTime: $0.1)
        }
        let destination = Waypoint(location: route.destination, landings: landing.destination, taxiTime: taxi.destination)
        let waypoints = [origin] + intermediates + [destination]

        // Combine waypoints and combine them with the cross-country data
        let crossCountryLegs: [(Waypoint, TimeInterval, Waypoint)] = waypoints.windows(of: 2).enumerated().map { (index, waypoints) in
            (waypoints.first!, crossCountry.durations[index], waypoints.last!)
        }

        // Split each cross-country leg up into XC and TP legs
        var legs: [Leg] = []
        for (i, (origin, travelTime, destination)) in crossCountryLegs.enumerated() {
            // Boundary condition, add traffic pattern circuits for the first airport if applicable
            if i == 0 && origin.landings.count > 0 {
                let waypoint = origin.extract(crossCountryLanding: false, consumeTaxiTime: true)
                legs.append(Leg.TrafficPatterns(waypoint, waypoint.landings.time))
            }

            // Check if origin and destination are the same
            if origin.location == destination.location {
                let origin = origin.extract(crossCountryLanding: false, consumeTaxiTime: true)
                let destination = destination.extract(crossCountryLanding: false, consumeTaxiTime: true)
                let combined = origin.merge(with: destination)!
                legs.append(Leg.TrafficPatterns(combined, combined.landings.time + travelTime))
            } else {
                let crossCountryOrigin = origin.extract(crossCountryLanding: false, consumeTaxiTime: true)
                let crossCountryDestination = destination.extract(crossCountryLanding: true, consumeTaxiTime: destination.landings.count == 1)
                assert(crossCountryOrigin.landings.count == 0)
                assert(crossCountryOrigin.landings.time == 0)
                assert(crossCountryDestination.landings.count == 1)
                assert(crossCountryDestination.landings.time == 0)
                legs.append(Leg.CrossCountry(crossCountryOrigin, travelTime, crossCountryDestination))

                // Add traffic patterns at the destination if applicable
                if destination.landings.count > 0 {
                    let waypoint = destination.extract(crossCountryLanding: false, consumeTaxiTime: true)
                    legs.append(Leg.TrafficPatterns(waypoint, waypoint.landings.time))
                }
            }
        }

        // Convert the legs into logbook entries by iterating them and adding up the times
        var tracker = TimeTracker(wallTime: route.startupTime, hobbsTime: route.startupHobbs)
        var logbookEntries: [LogbookEntry] = []
        for (i, leg) in legs.enumerated() {
            switch leg {
            case .CrossCountry(let origin, let travelTime, let destination):
                logbookEntries.append(
                    LogbookEntry(
                        origin: origin.location,
                        destination: destination.location,
                        blockStart: tracker.wallTime,
                        departure: tracker.add(taxi: origin.taxiTime),
                        hobbsStart: tracker.hobbsTime,
                        hobbsEnd: tracker.add(flight: travelTime),
                        arrival: tracker.wallTime,
                        blockEnd: tracker.add(taxi: destination.taxiTime),
                        landings: destination.landings.count)
                )
            case .TrafficPatterns(let waypoint, let flightTime):
                let isFirst = i == 0
                let isLast = i == legs.count - 1

                let startTaxi: TimeInterval
                let endTaxi: TimeInterval

                if isFirst {
                    startTaxi = waypoint.taxiTime
                    endTaxi = 0
                } else if isLast {
                    startTaxi = 0
                    endTaxi = waypoint.taxiTime
                } else {
                    startTaxi = waypoint.taxiTime / 2
                    endTaxi = waypoint.taxiTime / 2
                }

                logbookEntries.append(
                    LogbookEntry(
                        origin: waypoint.location,
                        destination: waypoint.location,
                        blockStart: tracker.wallTime,
                        departure: tracker.add(taxi: startTaxi),
                        hobbsStart: tracker.hobbsTime,
                        hobbsEnd: tracker.add(flight: flightTime),
                        arrival: tracker.wallTime,
                        blockEnd: tracker.add(taxi: endTaxi),
                        landings: waypoint.landings.count)
                )
            }
        }

        print(self)
        print(legs)
//        print(logbookEntries)
        print("--------")
        print("actual:")
        print("\tflight: \(route.flightTime / 60)")
        print("\twall: \(route.blockTime / 60)")
        print("\ttaxi: \(route.taxiTime / 60)")
        print("expected:")
        print("\tflight: \((route.shutdownHobbs - route.startupHobbs) / 60)")
        print("\twall: \((route.shutdownTime - route.startupTime) / 60)")
        print("\ttaxi: \(((route.shutdownTime - route.startupTime) - (route.shutdownHobbs - route.startupHobbs)) / 60)")
        print("accumulated:")
        print("\tflightXC: \(crossCountry.durations.reduce(0) { $0 + $1 } / 60)")
        print("\tflightTP: \(landing.trafficPatternTime / 60)")
        print("\ttaxi: \((taxi.origin + taxi.destination + taxi.intermediates.reduce(0) { $0 + $1 }) / 60)")
        print("wallTimes:")
        print("\ttracked: \(tracker.wallTime)")
        print("\troute: \(route.shutdownTime)")

        assert(tracker.wallTime == route.shutdownTime, "expected and actual wall time did not match")
        assert(tracker.hobbsTime == route.shutdownHobbs, "expected and actual hobbs time did not match")

        return logbookEntries
    }
}
