//
//  HighlightWaveView.swift
//  JSurf
//
//  Created by Jay Steele on 09/04/2024.
//

import SwiftUI

// struct Surf_Preferences (include wave height, period, form, power, wind speed, min-stars??) -> no map waveStats to allow this as they are very similar


class Highlights {
    
    public var waves: [WaveStats]
    private var highlightWaves: [WaveStats]

    init(waves: [WaveStats]) {

        self.waves = waves
         
        // dummy data
        self.highlightWaves = Array(repeating: WaveStats(swellSize: 0.0, windDirection: "Default", swellPeriod: 0.0, windSpeed: 0.0, waveEnergy: 0.0, waveForm: "Default", formColor: "Color-Default"), count: 168)

    }
    //array will be 50 long?, top 20 wave
    
    //function to retrun true based on pivot and wavestat
    
    func comparePref(data: WaveStats, pref: WaveStats, pivot: Int) -> Bool {
        
        let sizeAllowance:Double = 3.0
        
        return (data.gnarlyRating >= pivot) && (data.swellSize > pref.swellSize - sizeAllowance && data.swellSize < pref.swellSize+sizeAllowance)
    }
    
    // should I find a better system than using arrays?
    func quickSortbyGnarlyRating(_ input: [WaveStats], startIndex:Int, endIndex: Int, pref: WaveStats? = nil)-> [WaveStats] {
        var inputArray = input
        if startIndex<endIndex {
            let pivot = inputArray[endIndex].gnarlyRating
            var index = startIndex

            for demo in startIndex..<endIndex {
                
                
                if (inputArray[demo].gnarlyRating >= pivot) {
                    (inputArray[index], inputArray[demo]) = (inputArray[demo], inputArray[index])
                    index += 1
                }
            }
            (inputArray[index], inputArray[endIndex]) = (inputArray[endIndex], inputArray[index])
            inputArray = quickSortbyGnarlyRating(inputArray, startIndex: startIndex, endIndex: index-1)
            inputArray = quickSortbyGnarlyRating(inputArray, startIndex: index+1, endIndex: endIndex)
        }
        
        
    
        
        
        return inputArray
    }
    
    func sortByPreference(to preference: WaveStats, waveStatsArray: [WaveStats]) -> [WaveStats] {
        return waveStatsArray.sorted { (wave1, wave2) -> Bool in
            // calulate what is closest to pref
            let distance1 = wave1.distance(to: preference)
            let distance2 = wave2.distance(to: preference)
            return distance1 < distance2
        }
    }

    
    // Takes in preferences, waveStats struct
    //map between times 6-22 factor this into algorithm
    
    func getAndMapHighlightWaves(preference: WaveStats?) -> [WaveStats] {
        // recursive function to look through waveStats and but them in an array, ordered best to worst ->
        
        if preference != nil {
            return sortByPreference(to: preference!, waveStatsArray: self.waves)
            
        }
        // rate by my gnrlyRating and best Form?
        return quickSortbyGnarlyRating(self.waves, startIndex: 0, endIndex: self.waves.count-1)
        
        
        
    }
    // when called uses this to return best wave waves? in array of another custom struct (one with rating, times) these can be mapped to a scrollable card in the highlightWaveView <--
    
    //should I have a function that takes in Initial and changes it to waveStats but with a timeAssociated to it?
    
    // ** update waveStats to take UTC time code from Initial, that way I can have a generic function to match the time in highlights? **
}

// create a ux container for stat card??

struct HighlightWaveView: View {
    
    let MAX_REC_SIZE = 250.0;
    
    @Binding var waveStats: [WaveStats]
    let highlights: Highlights
    @State var highlightsArr: [WaveStats]
    @State var pos = 0
    
    // kind of got it
    // clean it up visually no padding, take on videos to make rectangle more neat
    
    // create new script to manage minmized version
    // add a feature where user can go to where waves our best based on their pref
    // need a feature to insert their pref (save to cache for now in future let them create an account using Auth0 to save it as metadata?)
    
    init(waveStats: Binding<[WaveStats]>, preference: Binding<WaveStats>?) {
        _waveStats = waveStats
        highlights = Highlights(waves: waveStats.wrappedValue)
        
    
        highlightsArr = highlights.getAndMapHighlightWaves(preference: preference?.wrappedValue)
        
    }
    
    func roundDoubleToString(d: Double, dec: Int = 1) -> String {
        let result = Double(round(10 * d)/10)
        return String(format: "%.\(dec)f", result)
    }
    
    func updatePos(isRight: Bool) {
        let sub: Int = isRight ? 1 : -1
        var tempPos = self.pos + sub
        
        
        if(tempPos > self.highlightsArr.count-1) {
            tempPos = 0
        }
        
        if(tempPos < 0) {
            tempPos = self.highlightsArr.count-1
        }
        
        self.pos = tempPos
    }
    
    
    var body: some View {
        // Take in a beachStats? Map data from that
        
        // Model for desired wave height
        
        // Desired swell Period
        
        //Default best by rating
        
        //create array sort by best gnarly rating
        
        // wave horizontal view will have all the data -> could it not return the top 10 of waves
        
        //Show in a card -- scrollable? Click to see next best wave for each beach
        
        //go through best gnarly ratings, get index and reverse that index to get the day - might need a system to get the date -> should I just attach it to this struct??
        
        // make a class or a function that takes in a certain struct which can return a struct with the correct struct pairing to show in this view, would be best if this struct could have waveStats and time on it? Then return this struct with the array either ordered (0 being best waves) or create a view function that handpicks the object by gnarly rating?
        
        
        
        VStack {
            VStack {
                
                // Date
                HStack {
                    Rectangle().stroke(Color(highlightsArr[pos].formColor), lineWidth: 2).foregroundColor(.white).frame(width: 180, height: 20).overlay(
                        HStack {
                            Button(action: {updatePos(isRight: false)}) {
                                Image.init(systemName: "arrow.left")
                            }
                            
                            Text("Wave pos: \(pos+1)")
                            Button(action: {updatePos(isRight: true)}) {
                                Image(systemName: "arrow.right")
                                //arrow
                            }
                        }).padding(.bottom, 2).foregroundStyle(.black)
                    
                    
                }
                
                Rectangle().stroke(Color(highlightsArr[pos].formColor), lineWidth: 4).foregroundColor(.white).frame(width: 120, height: 20).overlay(
                    Text(highlightsArr[pos].time ?? "No Time").foregroundStyle(.black).bold()
                ).padding(.bottom, 2)
                
                // Stats
                
                Rectangle().stroke(Color(highlightsArr[pos].formColor), lineWidth: 8).foregroundColor(.white).frame(width: 120, height: 150).overlay(
                    //vstack to table these elements - earch this up!
                    VStack(spacing: 2) {
                        
                        //gnarly rating based off the amount of stars
                        HStack {
                            if((highlightsArr[pos].waveEnergy) > 2500) {
                                Image(systemName: "x.circle").resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15)
                                    .foregroundColor(.black).padding(.bottom, 8)
                            } else {
                                ForEach(0..<(highlightsArr[pos].gnarlyRating/2), id:\.self) { number in
                                    Image(systemName: "star.fill").resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 9)
                                        .foregroundColor(.black).padding(.bottom, 8)
                                    
                                }
                            }
                        }
                        
                        Text("\(roundDoubleToString(d: highlightsArr[pos].swellSize))ft")
                        Text("\(roundDoubleToString(d: highlightsArr[pos].swellPeriod))s")
                        
                        HStack {
                            Text(highlightsArr[pos].windDirection);
                            
                            Text(roundDoubleToString(d:highlightsArr[pos].windSpeed, dec: 0)).fontWeight(.regular).frame(width: 15, height:10, alignment: .center).font(.system(size: 12)).padding(5)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1))
                            
                            
                        }
                        
                        
                        Text("\(roundDoubleToString(d: highlightsArr[pos].waveEnergy, dec: 0))kj")
                    }.bold().foregroundStyle(.black).padding().frame(maxWidth: 125, maxHeight: 160).font(.system(size: 15))
                ).padding(.bottom, 10)
                
                
            }.bold().foregroundStyle(.white).padding().frame(maxWidth: .infinity, maxHeight: .infinity).font(.system(size: 15))
        }.background(RoundedRectangle(cornerSize: /*@START_MENU_TOKEN@*/CGSize(width: 20, height: 10)/*@END_MENU_TOKEN@*/).stroke(.black, lineWidth: 2).foregroundColor(.white).shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).frame(maxWidth: MAX_REC_SIZE, maxHeight: MAX_REC_SIZE))
    }
    
}

    
    
    
    
    struct HighlightWavePreview : PreviewProvider {
        
        
        @State static var dummy = GetDummy.dummyWaveStat
        @State static var pref = WaveStats(swellSize: 4.5, windDirection: "nil", swellPeriod: 14.0, windSpeed: 5.0, waveEnergy: 0, waveForm: "Glass", formColor: "nil")
        
        static var previews: some View {
            HighlightWaveView(waveStats: $dummy, preference: $pref)
            
        }
        
    }


