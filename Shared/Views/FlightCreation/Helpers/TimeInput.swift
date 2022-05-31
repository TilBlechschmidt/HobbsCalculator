//
//  TimeInput.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 26.03.22.
//

import SwiftUI

struct TimeInput: View {
    @FocusState private var inputFocused: Bool
    @FocusState private var fakeInputFocused: Bool

    @State var hours: String
    @State var minutes: String

    @State var ignoreChanges: Bool = false
    @State var useNumpad: Bool = false

    let parser: TimeParser
    let value: Binding<TimeInterval?>

    init(value: Binding<TimeInterval?>, parser: TimeParser = TimeParser(allowInfiniteHours: false)) {
        self.parser = parser
        self.value = value

        if let currentValue = value.wrappedValue {
            let (hours, minutes) = parser.split(currentValue)
            self.hours = String(format: "%02d", hours)
            self.minutes = String(format: "%02d", minutes)
        } else {
            self.hours = "00"
            self.minutes = "00"
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            TextField("00", text: $hours)
                .fixedSize()
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .disabled(true)
            Text(":")
            TextField("00", text: $minutes)
                .fixedSize()
                .monospacedDigit()
                .multilineTextAlignment(.leading)
                .focused($inputFocused)
                .keyboardType(.numberPad)
        }
            // Updating the value in the same render cycle makes SwiftUI complain
            // but for now it works.
            .onChange(of: hours, perform: overflowHandling)
            .onChange(of: minutes, perform: overflowHandling)
            // Moves cursor to the end of the input when focused
            .onChange(of: inputFocused) { _ in
                if inputFocused {
                    ignoreChanges = true
                    let text = minutes
                    minutes = ""
                    DispatchQueue.main.async {
                        minutes = text
                        ignoreChanges = false
                    }
                }
            }
            // Moves focus from fake input to target input
            // Workaround for a bug where a change from alphanumeric keyboard to numberPad causes the scrollview to glitch out
            .onChange(of: fakeInputFocused) { _ in
                if fakeInputFocused {
                    inputFocused = true
                }
            }
            .overlay {
                GeometryReader { geometry in
                    TextField("", text: Binding.init(get: { "" }, set: { _ in }))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(.background)
                        // We can not use .clear or 0 or any value below 0.05 because then SwiftUI just removes the focus target and the .focused will not work
                        .opacity(0.05)
                        .focused($fakeInputFocused)
                }
            }
    }

    func overflowHandling(_: String) {
        guard !ignoreChanges else { return }

        var hours = hours
        var minutes = minutes

        if hours.count + minutes.count > 10 {
            minutes.removeLast()
        }

        hours = hours
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")

        minutes = minutes
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")

        if minutes.count > 2 {
            let prefix = minutes.prefix(minutes.count - 2)
            minutes.removeFirst(prefix.count)
            hours += prefix
        }

        if minutes.count < 2 && hours.count > 0 {
            let suffix = hours.suffix(2 - minutes.count)
            hours.removeLast(suffix.count)
            minutes = suffix + minutes
        } else if minutes.count < 2 {
            minutes = String(repeating: "0", count: 2 - minutes.count) + minutes
        }

        while hours.starts(with: "0") {
            hours.removeFirst()
        }

        while hours.count < 2 {
            hours = "0" + hours
        }

        self.hours = hours
        self.minutes = minutes
        self.value.wrappedValue = parser.parse("\(hours):\(minutes)")
    }
}

struct TimeInput_Previews: PreviewProvider {
    private struct ExampleView: View {
        @State var value: TimeInterval? = 8932.0

        var body: some View {
            TimeInput(value: $value)
        }
    }

    static var previews: some View {
        ExampleView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
