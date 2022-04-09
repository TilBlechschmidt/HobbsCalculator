//
//  TimeStepperRow.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import SwiftUI

struct TimeStepperRow: View {
    let value: Binding<Int>
    let range: ClosedRange<Int>
    let icon: String
    let label: String

    var body: some View {
        StepperRow(value: value, range: range, icon: icon, label: label, unit: "min")
    }
}

//struct TimeStepperRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeStepperRow()
//    }
//}
