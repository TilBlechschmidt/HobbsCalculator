//
//  TimeParser.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 27.03.22.
//

import Foundation

struct TimeParser {
    let allowInfiniteHours: Bool

    func normalize(_ text: String) -> String {
        text.replacingOccurrences(of: ".", with: ":")
            .replacingOccurrences(of: ",", with: ":")
    }

    func parse(_ text: String) -> TimeInterval? {
        let components = normalize(text).split(separator: ":", maxSplits: 2)

        let rawHours = components.first ?? "0"
        let rawMinutes = components.count > 1 ? components[1] : "0"

        guard let hours = Int(rawHours), let minutes = Int(rawMinutes), minutes < 60, allowInfiniteHours || hours < 24 else {
            return nil
        }

        return Double((hours * 60 + minutes) * 60)
    }

    func split(_ time: TimeInterval) -> (Int, Int) {
        Int(time / 60).quotientAndRemainder(dividingBy: 60)
    }

    func format(_ time: TimeInterval) -> String {
        let (hours, minutes) = self.split(time)

        if time < 0 {
            return String(format: "-%02d:%02d", abs(hours), abs(minutes))
        } else {
            return String(format: "%02d:%02d", hours, minutes)
        }
    }
}
