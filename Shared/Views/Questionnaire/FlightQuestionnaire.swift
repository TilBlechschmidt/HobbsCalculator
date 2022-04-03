//
//  FlightQuestionnaire.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 27.03.22.
//

import SwiftUI

struct FlightInformationQuestionnaire: View {
    let lastHobbs: HobbsValue?
    let lastLocation: LocationIdentifier?

    @State var originPatterns: Bool?
    @State var startup: StartupInformation?
    @State var departures: [DepartureInformation] = []

    let onSubmit: (OldFlightInformation) -> ()

    var latestHobbs: HobbsValue {
        if let lastDeparture = departures.last {
            return lastDeparture.hobbs
        } else if let startup = startup {
            return startup.hobbs
        } else {
            return 0.0
        }
    }

    var latestTimestamp: HobbsValue {
        if let startup = startup {
            let startupTime = startup.timestamp
            let cumulativeHobbs = latestHobbs - startup.hobbs
            return startupTime + cumulativeHobbs
        } else {
            return 0.0
        }
    }

    var body: some View {
        if startup == nil {
            StartupQuestionView(lastLocation: lastLocation, lastHobbs: lastHobbs, onSubmit: handleStartup)
        } else if originPatterns == nil {
            Form {
                Text("Did you fly circuits at your startup location prior to departure?")
                Button("Yes") { originPatterns = true }
                Button("No") { originPatterns = false }
            }
        } else if originPatterns == true, let startupLocation = startup?.location {
            DepartureQuestionView(minimumTimestamp: latestTimestamp, minimumHobbs: latestHobbs, prefilledLocation: startupLocation, onSubmit: handleDeparture)
        } else {
            DepartureQuestionView(minimumTimestamp: latestTimestamp, minimumHobbs: latestHobbs, onSubmit: handleDeparture)
        }
    }

    func handleStartup(info: StartupInformation) {
        startup = info
    }

    func handleDeparture(info: DepartureQuestionView.Output) {
        switch info {
        case .Departure(let departure):
            departures.append(departure)
        case .Shutdown(let shutdown):
            onSubmit(OldFlightInformation(startup: startup!, departures: departures, shutdown: shutdown))
        }
    }
}

struct FlightQuestionnaire: View {
    let lastHobbs: HobbsValue?
    let lastLocation: LocationIdentifier?
    let onSubmit: (Flight) -> ()

    @State var flight: OldFlightInformation? = nil

    var body: some View {
        if flight == nil {
            FlightInformationQuestionnaire(lastHobbs: lastHobbs, lastLocation: lastLocation, onSubmit: { flight = $0 })
        } else if let flight = flight {
            TimeDistributionView(flight: flight, onSubmit: onSubmit)
        }
    }
}

struct FlightQuestionnaire_Previews: PreviewProvider {
    static var previews: some View {
        FlightQuestionnaire(lastHobbs: nil, lastLocation: nil) { _ in }
    }
}
