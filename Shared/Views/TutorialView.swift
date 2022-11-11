//
//  TutorialView.swift
//  HobbsCalculator
//
//  Created by Til Blechschmidt on 31.05.22.
//

import SwiftUI

struct TutorialView: View {
    var body: some View {
        Text("Coming soon, play around with the app in the meantime.")
        // Important notes:
        // - Flight != Trip, one trip == multiple flights
        //   - One flight goes from engine start to shutdown
        // - Only write down Hobbs & UTC time, nothing else is required
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}
