//
//  CrossCountryInformationView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

struct CrossCountryInformationView: View {
    static let minimumDurationPerLeg: Int = 5 * 60
    let colors = [
        Color(hex: "f7b267"),
        Color(hex: "f79d65"),
        Color(hex: "f4845f"),
        Color(hex: "f27059"),
        Color(hex: "f25c54")
    ]

    let route: RouteInformation
    let landing: LandingInformation
    let crossCountryTime: Int

    @State var durations: [Int]
    @GestureState private var initialDurations: [Int]? = nil

    var crossCountryInformation: CrossCountryInformation {
        CrossCountryInformation(durations: durations.map { TimeInterval($0) })
    }

    init(_ route: RouteInformation, _ landing: LandingInformation) {
        self.route = route
        self.landing = landing

        let legs = route.legs
        let flightTime = Int(round(route.flightTime))

        if legs.count == 1 {
            self.durations = [flightTime]
            self.crossCountryTime = 0
        } else if !legs.isEmpty {
            let trafficPatternTime = landing.trafficPatternTime
            self.crossCountryTime = flightTime - trafficPatternTime

            if crossCountryTime < 0 {
                fatalError("No XC time remaining. Did someone enter too many landings without it being caught?")
            }

            let (quotient, remainder) = crossCountryTime.quotientAndRemainder(dividingBy: legs.count)
            self.durations = route.legs.map { _ in quotient }
            self.durations[0] += remainder
        } else {
            fatalError("No legs present in flight")
        }
    }

    var body: some View {
        if crossCountryTime == 0 {
            TaxiInformationView(route, landing, crossCountryInformation)
        } else {
            VStack {
                Text("Distribute the time for each leg")
                    .padding()
                    .multilineTextAlignment(TextAlignment.leading)

                GeometryReader { geo in
                    VStack(spacing: 0) {
                        ForEach(route.legs.indices, id: \.self) { index in
                            let duration = durations[index]
                            let leg = route.legs[index]
                            let percentage = Double(duration) / Double(crossCountryTime)
                            let height = percentage * geo.size.height
                            let isFirst = index == 0
                            let isLast = index == durations.count - 1
                            let corners: UIRectCorner = isFirst ? [.topLeft, .topRight] : (isLast ? [.bottomLeft, .bottomRight] : [])
                            let idx: Int = index

                            Rectangle()
                                .frame(height: height)
                                .foregroundColor(.clear)
                                .overlay {
                                    Rectangle()
                                        .frame(maxWidth: 150)
                                        .foregroundColor(colors[index % colors.count])
                                        .cornerRadius(20, corners: corners)
                                }
                                .overlay {
                                    VStack {
                                        if isFirst {
                                            SliderLabelView(leg.origin, inverted: true, hideDivider: true)
                                        }
                                        Spacer()
                                        SliderLabelView(leg.destination, rightLabel: "+\(duration / 60) min", hideDivider: isLast)
                                    }
                                }
                                .ifCondition(!isLast) {
                                    $0.gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                handleTranslation(of: idx, by: value.translation, from: initialDurations ?? durations, inContainerOfHeight: geo.size.height)
                                            }
                                            .updating($initialDurations) { value, initialDurations, transaction in
                                                initialDurations = initialDurations ?? durations
                                            }
                                    )
                                }
                        }
                    }
                }
                    .padding(.bottom, 50)
                    .padding(.top, 25)
            }
                .navigationTitle("Flight time")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        NavigationLink("Next") {
                            TaxiInformationView(route, landing, crossCountryInformation)
                        }
                    }
                }
        }
    }

    func handleTranslation(of index: Int, by translation: CGSize, from initial: [Int], inContainerOfHeight height: Double) {
        let deltaPixels = translation.height
        let deltaPercentage = deltaPixels / height
        var deltaTime = Int(round(Double(crossCountryTime) * deltaPercentage))

        if deltaTime > 0 {
            deltaTime = min(deltaTime, initial[index + 1] - Self.minimumDurationPerLeg)
        } else {
            deltaTime = max(deltaTime, -initial[index] + Self.minimumDurationPerLeg)
        }

        var newDurations = initial[...]
        newDurations[index] += deltaTime
        newDurations[index + 1] -= deltaTime
        durations = Array(newDurations)
    }
}

struct CrossCountryInformationView_Previews: PreviewProvider {
    static let flight = RouteInformation(
        startupTime: 46800.0,
        startupHobbs: 29160000.0,
        origin: "EDDH",
        waypoints: ["EDXQ", "EDHE"],
        destination: "EDDH",
        shutdownTime: 52200.0,
        shutdownHobbs: 29164080.0)

    static let landing = LandingInformation(
        origin: 0,
        intermediates: [6],
        destination: 1,
        timePerTrafficPatternCircuit: 120)

    static var previews: some View {
        NavigationView {
            CrossCountryInformationView(flight, landing)
        }
    }
}
