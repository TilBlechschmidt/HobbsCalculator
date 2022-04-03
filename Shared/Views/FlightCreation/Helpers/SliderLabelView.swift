//
//  SliderLabelView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 02.04.22.
//

import SwiftUI

struct SliderLabelView: View {
    let leftLabel: String
    let rightLabel: String
    let inverted: Bool
    let hideDivider: Bool

    init(_ leftLabel: String, rightLabel: String = "", inverted: Bool = false, hideDivider: Bool = false) {
        self.leftLabel = leftLabel
        self.rightLabel = rightLabel
        self.inverted = inverted
        self.hideDivider = hideDivider
    }

    var body: some View {
        HStack {
            HStack {
                Spacer()
                Text(leftLabel)
            }.frame(minWidth: 0, maxWidth: .infinity)

            Rectangle()
                .foregroundColor(.gray.opacity(hideDivider ? 0 : 0.25))
                .frame(width: 150, height: 2)

            HStack {
                Text(rightLabel)
                Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity)
        }
            .font(.caption)
            .foregroundColor(.gray)
            .offset(y: (inverted ? -1 : 1) * 7.5)
    }
}

struct SliderLabelView_Previews: PreviewProvider {
    static var previews: some View {
        SliderLabelView("EDXQ", rightLabel: "60min", inverted: false, hideDivider: false)
    }
}
