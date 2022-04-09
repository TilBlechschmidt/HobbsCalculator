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

    @EnvironmentObject var airportRegistry: AirportRegistry

    var matchedAirportName: String? {
        airportRegistry.airports[value.wrappedValue]?.name
    }

    init(_ title: String, location: Binding<LocationIdentifier>) {
        self.title = title
        self.value = location
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField(title, text: value.animation())

            if let airportName = matchedAirportName {
                HStack {
                    Spacer()
                    Text(airportName)
                        .font(.caption.smallCaps())
                }.transition(.move(edge: .trailing))
            }
        }
            .mask(Rectangle())
            .multilineTextAlignment(.trailing)
            .onChange(of: value.wrappedValue) { _ in value.wrappedValue = value.wrappedValue.uppercased() }
    }
}

struct LocationInput_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var value = ""

        var body: some View {
            List {
                LabelledValue(icon: "airplane.departure", label: "Origin") {
                    LocationInput("EDDH", location: $value)
                }
            }
                .environmentObject(AirportRegistry.default)
                .listStyle(.insetGrouped)
                .multilineTextAlignment(.trailing)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
