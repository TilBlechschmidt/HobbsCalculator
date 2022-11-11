//
//  SimpleTimeInput.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 11.11.22.
//

import SwiftUI

struct TimeInput: View {
    @State var text: String

    let parser: TimeParser
    let value: Binding<TimeInterval?>

    init(value: Binding<TimeInterval?>, parser: TimeParser = TimeParser(allowInfiniteHours: false)) {
        self.parser = parser
        self.value = value

        if let currentValue = value.wrappedValue {
            let (hours, minutes) = parser.split(currentValue)
            _text = State(wrappedValue: String(format: "%02d:%02d", hours, minutes))
        } else {
            _text = State(wrappedValue: "")
        }
    }

    var body: some View {
        TextField("00:00", text: $text)
            .fixedSize()
            .monospacedDigit()
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .onChange(of: text, perform: separatorReplacement)
    }

    func separatorReplacement(src: String) {
        text = src.replacingOccurrences(of: ",", with: ":")
        value.wrappedValue = parser.parse(text)
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
