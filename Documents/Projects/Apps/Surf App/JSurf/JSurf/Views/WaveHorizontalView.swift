//
//  WaveHorizontalView.swift
//  JSurf
//
//  Created by Jay Steele on 18/02/2024.
//

import SwiftUI


struct WaveHorizontalView: View {
    
    @Binding var waveStats: [WaveStats]
    @Binding var day: Int
    @State var waveModel: WaveModel = WaveModel()
    
    //atempting vars with cache
    @State private var selectedTime: CGFloat = 0
    @State private var scrollViewOffset: CGPoint = .zero
    
    
    init(waveStats: Binding<[WaveStats]>, day: Binding<Int>) {
        _waveStats = waveStats
        _day = day
    }
    
    func mapTime(num: Int) -> String {
        switch num {
        case 0...9:
            return "0\(num):00"
        case 10...23:
            return "\(num):00"
        default:
            return "Time Incompatible"
        }
    }
    
    func mapDoubleToString(d: Double) -> String {
        return String(format: "%.0f", d)
    }
    //swiftUi function to map windSpeed to int (stirng)
    
    var body: some View {
        
        let hours = 24 // max 24 hours shown
        let gnarlyRisk: Double = 2500
        
        ScrollViewReader { proxy in
            HStack(spacing: 0) {
                //SIDE_BAR//--
                VStack {
                    VStack(spacing: 2) {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .overlay(
                                Image(systemName: "clock")
                                    .foregroundColor(.black)
                            ).cornerRadius(5.0).padding(.bottom, 5)
                        
                        //side bar probs take out for now
                        Rectangle().stroke(Color("Color-Default"), lineWidth: 6).foregroundColor(.white).frame(width: 28, height: 150).overlay(
                            VStack(spacing: 2) {
                                Image(systemName: "water.waves")
                                Image(systemName: "timer")
                                Image(systemName: "wind")
                                Image(systemName: "bolt")
                            }.bold().foregroundStyle(.black).frame(maxHeight: 160).font(.system(size: 15))
                        ).padding(.bottom, 10)
                        
                        Rectangle()
                            .foregroundColor(Color.white)
                            .overlay(
                                Image(systemName: "figure.surfing")
                                    .foregroundColor(Color("Color-Default"))
                            ).cornerRadius(5.0)
                        
                    }.bold().padding().frame(maxWidth: .infinity, maxHeight: .infinity).font(.system(size: 15))
                }.frame(width: 30, height: 250).cornerRadius(15)
                    .shadow(radius: 2)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 2) {
                        Spacer(minLength: 1)
                        ForEach(0..<hours, id: \.self) { index in
                            VStack {
                                
                                HStack {
                                    VStack(spacing: 2) {
                                        Rectangle()
                                            .foregroundColor(Color.white)
                                            .overlay(
                                                Text(mapTime(num: index))
                                                    .foregroundColor(.black)
                                            ).cornerRadius(5.0).padding(.bottom, 5)
                                        
                                        Rectangle().stroke(Color(self.waveStats[index+day].formColor), lineWidth: 8).foregroundColor(.white).frame(width: 120, height: 150).overlay(
                                            //vstack to table these elements - earch this up!
                                            VStack(spacing: 2) {
                                                let gnarlyRating = (self.waveModel.gnarlyRating(swellHeight: self.waveStats[index+day].swellSize, wavePeriod: self.waveStats[index+day].swellPeriod, waveForm: self.waveStats[index+day].waveForm, windSpeed: self.waveStats[index+day].windSpeed))/2
                                                
                                                //gnarly rating based off the amount of stars
                                                HStack {
                                                    if((self.waveStats[index+day].waveEnergy) > gnarlyRisk) {
                                                        Image(systemName: "x.circle").resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 15)
                                                            .foregroundColor(.black).padding(.bottom, 8)
                                                    } else {
                                                        ForEach(0..<gnarlyRating, id:\.self) { number in
                                                            Image(systemName: "star.fill").resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width: 9)
                                                                .foregroundColor(.black).padding(.bottom, 8)
                                                            
                                                        }
                                                    }
                                                }
                                                
                                                Text(String(self.waveStats[index+day].swellSize) +  "ft")
                                                Text(String(self.waveStats[index+day].swellPeriod) +  "s")
                                                
                                                HStack {
                                                    Text(self.waveStats[index+day].windDirection)
                                                    
                                                    Text(mapDoubleToString(d: self.waveStats[index+day].windSpeed)).fontWeight(.regular).frame(width: 15, height:10, alignment: .center).font(.system(size: 12)).padding(5)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(Color.black, lineWidth: 1))
                                                    
                                                    
                                                }
                                                
                                                //Text(self.waveStats[index+day].windDirection)
                                                
                                                
                                                Text(String(self.waveStats[index+day].waveEnergy) +  "kj")
                                            }.bold().foregroundStyle(.black).padding().frame(maxWidth: 125, maxHeight: 160).font(.system(size: 15))
                                        ).padding(.bottom, 10)
                                        
                                        Rectangle()
                                            .foregroundColor(Color.white)
                                            .overlay(
                                                Text(self.waveStats[index+day].waveForm)
                                                    .foregroundColor(Color(self.waveStats[index+day].formColor)).font(.title3).italic()
                                            ).cornerRadius(5.0)
                                        
                                    }.bold().foregroundStyle(.white).padding().frame(maxWidth: .infinity, maxHeight: .infinity).font(.system(size: 15))
                                    
                                }.frame(width: 125, height: 250).cornerRadius(15)
                                    .shadow(radius: 2).onAppear {
                                        proxy.scrollTo(selectedTime, anchor: .top)
                                        
                            
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct WaveHorizontalPreview : PreviewProvider {
    
    
    @State static var dummy = GetDummy.dummyWaveStat
    @State static var day = 0

    static var previews: some View {
        WaveHorizontalView(waveStats: $dummy, day: $day)
        
    }

}

