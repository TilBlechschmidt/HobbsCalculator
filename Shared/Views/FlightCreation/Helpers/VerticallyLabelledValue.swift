//
//  VerticallyLabelledValue.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 03.04.22.
//

import SwiftUI

struct VerticallyLabelledValue: View {
    let label: String
    let value: String

    init(_ value: String, label: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        VStack {
            Text(label).foregroundColor(.secondary)
            Text(value).bold()
        }
    }
}

struct VerticallyLabelledValue_Previews: PreviewProvider {
    static var previews: some View {
        VerticallyLabelledValue("01:30", label: "Block")
    }
}
