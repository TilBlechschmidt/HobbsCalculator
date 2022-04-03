//
//  LocationInput.swift
//  HobbsCalculator (iOS)
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

struct LocationInput: View {
    var title: String
    var value: Binding<LocationIdentifier>

    init(_ title: String, location: Binding<LocationIdentifier>) {
        self.title = title
        self.value = location
    }

    var body: some View {
        TextField(title, text: value)
            .onChange(of: value.wrappedValue) { _ in value.wrappedValue = value.wrappedValue.uppercased() }
    }
}

struct LocationInput_Previews: PreviewProvider {
    static var previews: some View {
        LocationInput("Hello", location: Binding(get: { "Value" }, set: { _ in }))
    }
}
