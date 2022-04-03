//
//  StartupQuestionView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 27.03.22.
//

import SwiftUI

struct StartupQuestionView: View {
    enum Step: Int, Hashable {
        case Location, Timestamp, Hobbs
    }

    @FocusState var focus: Step?
    @State var step: Step = .Location
    @State var location: LocationIdentifier
    @State var timestamp: Timestamp?
    @State var hobbs: HobbsValue?

    let onSubmit: (StartupInformation) -> ()

    init(lastLocation: LocationIdentifier? = nil, lastHobbs: HobbsValue? = nil, onSubmit: @escaping (StartupInformation) -> ()) {
        self.location = lastLocation ?? ""
        self.hobbs = lastHobbs
        self.onSubmit = onSubmit
        self.focus = .Location
    }

    var inputValid: Bool {
        switch step {
        case .Location:
            return !location.isEmpty
        case .Timestamp:
            return timestamp != nil
        case .Hobbs:
            return hobbs != nil
        }
    }

    var body: some View {
        Form {
            switch step {
            case .Location:
                Text("Startup location?")
                TextField("EDDH", text: $location)
                    .focused($focus, equals: Step.Location)
                    .onChange(of: location) { _ in location = location.uppercased() }
            case .Timestamp:
                Text("Startup time?")
                TimeInput(value: $timestamp)
                    .focused($focus, equals: Step.Timestamp)
            case .Hobbs:
                Text("Pre-startup hobbs value?")
                TimeInput(value: $hobbs, parser: TimeParser(allowInfiniteHours: true))
                    .focused($focus, equals: Step.Hobbs)
            }

            Button("Submit", action: submit)
                .disabled(!inputValid)
        }
            .onSubmit(submit)
    }

    func submit() {
        switch step {
        case .Location:
            guard !location.isEmpty else { return }
            step = .Timestamp
            focus = step
        case .Timestamp:
            guard timestamp != nil else { return }
            step = .Hobbs
            focus = step
        case .Hobbs:
            guard let hobbs = hobbs, let time = timestamp else { return }
            onSubmit(StartupInformation(location: location, timestamp: time, hobbs: hobbs))
            focus = nil
        }
    }
}

struct StartupQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        StartupQuestionView { _ in }
    }
}
