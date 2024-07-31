//
//  SplashScreenView.swift
//  JSurf
//
//  Created by Jay Steele on 29/01/2024.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            withAnimation {
                Image("Splash-Image")
                    .resizable().transition(.scale)
            }
        }.ignoresSafeArea()
    }
}

#Preview {
    SplashScreenView()
}
