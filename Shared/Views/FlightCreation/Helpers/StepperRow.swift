//
//  StepperRow.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

struct StepperRow: View {
    let value: Binding<Int>
    let range: ClosedRange<Int>
    let icon: String
    let label: String
    let unit: String

    var body: some View {
        LabelledValue(icon: icon, label: label) {
            Stepper(value: value, in: range, label: {
                HStack {
                    Spacer()
                    Text("\(value.wrappedValue)\(unit.isEmpty ? "" : " \(unit)")")
                        .monospacedDigit()
                }
            })
        }
    }
}

struct StepperRow_Previews: PreviewProvider {
    static var previews: some View {
        StepperRow(value: Binding.constant(12), range: 0...30, icon: "airplane.arrival", label: "EDXQ", unit: "min")
    }
}
