//
//  DepartureQuestionView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 27.03.22.
//

import SwiftUI

struct DepartureQuestionView: View {
    enum Step: Int, Hashable {
        case Location, Action, Landings, Time, Hobbs
    }

    enum Output {
        case Departure(DepartureInformation)
        case Shutdown(ShutdownInformation)
    }

    @FocusState var focus: Step?
    @State var step: Step
    @State var location: LocationIdentifier
    @State var isShutdown: Bool = false
    @State var hobbs: HobbsValue?
    @State var timestamp: Timestamp?
    @State var landings: Int = 1

    let minimumTimestamp: Timestamp
    let minimumHobbs: HobbsValue
    let onSubmit: (Output) -> ()

    var inputValid: Bool {
        switch step {
            case .Location:
                return !location.isEmpty
            case .Action:
                return true
            case .Landings:
                return landings > 0
            case .Time:
                guard let timestamp = timestamp else { return false}
                return timestamp > minimumTimestamp
            case .Hobbs:
                // TODO Sanity check hobbs value (i.e. not more than 24h)
                guard let hobbs = hobbs else { return false }
                return hobbs > minimumHobbs
        }
    }

    init(minimumTimestamp: Timestamp, minimumHobbs: HobbsValue, prefilledLocation: LocationIdentifier? = nil, onSubmit: @escaping (Output) -> ()) {
        self.location = prefilledLocation ?? ""
        self.minimumTimestamp = minimumTimestamp
        self.minimumHobbs = minimumHobbs
        self.onSubmit = onSubmit

        if let prefilledLocation = prefilledLocation, !prefilledLocation.isEmpty {
            self.step = .Landings
        } else {
            self.step = .Location
        }

        self.focus = step
    }

    var body: some View {
        Form {
            switch step {
            case .Location:
                Text("Where did you go next")
                TextField("EDHE", text: $location)
                    .onChange(of: location) { _ in location = location.uppercased() }
                    .focused($focus, equals: Step.Location)
            case .Action:
                Text("What did you do there?")

                Button("Circuits & depart", action: submit).padding()

                Button("Land & shutdown", action: {
                    isShutdown = true
                    submit()
                }).padding()

                Button("Pass by", action: reset).padding()
            case .Landings:
                Text("How many landings?")
                Stepper("\(landings)", value: $landings)
            case .Time:
                Text("Shutdown time")
                TimeInput(value: $timestamp)
                    .focused($focus, equals: Step.Time)
            case .Hobbs:
                Text(isShutdown ? "Hobbs value post-shutdown" : "Hobbs value on departure")
                TimeInput(value: $hobbs, parser: TimeParser(allowInfiniteHours: true))
                    .focused($focus, equals: Step.Hobbs)
            }

            if step != .Action {
                Button("Submit", action: submit)
                    .disabled(!inputValid)
            }
        }.onSubmit(submit)
    }

    func reset() {
        step = .Location
        focus = .Location
        location = ""
        isShutdown = false
        hobbs = nil
        timestamp = nil
        landings = 1
    }

    func submit() {
        switch step {
        case .Location:
            guard !location.isEmpty else { return }
            step = .Action
        case .Action:
            step = .Landings
        case .Landings:
            guard landings > 0 else { return }
            step = isShutdown ? .Time : .Hobbs
        case .Time:
            guard timestamp != nil else { return }
            step = .Hobbs
        case .Hobbs:
            if isShutdown {
                guard let hobbs = hobbs, let timestamp = timestamp else { return }
                onSubmit(.Shutdown(ShutdownInformation(location: location, timestamp: timestamp, hobbs: hobbs, landings: landings)))
            } else {
                guard let hobbs = hobbs else { return }
                onSubmit(.Departure(DepartureInformation(location: location, hobbs: hobbs, landings: landings)))
            }

            reset()
        }

        focus = step
    }
}

struct DepartureQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        DepartureQuestionView(minimumTimestamp: 0.0, minimumHobbs: 0.0) { _ in }
    }
}
