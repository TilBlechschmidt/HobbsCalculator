//
//  View+Conditional.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

extension View {
    @ViewBuilder
    func ifCondition<TrueContent: View, FalseContent: View>(_ condition: Bool, then trueContent: (Self) -> TrueContent, else falseContent: (Self) -> FalseContent) -> some View {
        if condition {
            trueContent(self)
        } else {
            falseContent(self)
        }
    }

    @ViewBuilder
    func ifCondition<TrueContent: View>(_ condition: Bool, then trueContent: (Self) -> TrueContent) -> some View {
        if condition {
            trueContent(self)
        } else {
            self
        }
    }
}
