import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView().transition(.opacity)
                
            } else {
                Home()
            }
                        
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
