//
//  LoadingView.swift
//  JSurf
//
//  Created by Jay Steele on 14/02/2024.
//

import SwiftUI



struct LoadingView: View {
    @State private var animationAmount = 0.0
    var body: some View {
        HStack {
            ForEach(0..<3) { index in
                Circle().frame(width: 25, height: 25).scaleEffect(animationAmount).opacity(Double(3-index)/3).animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true).delay(0.25 * Double(index)), value: animationAmount).foregroundStyle(.black)
                
            }
            
        }.onAppear {

            self.animationAmount = 1.0            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //                Text("Loading...")
                //            }
            }
    }
}

#Preview {
    LoadingView()
}
