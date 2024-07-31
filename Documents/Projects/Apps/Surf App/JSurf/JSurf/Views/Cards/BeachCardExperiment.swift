import Foundation

import SwiftUI

struct WaveStats: Hashable, Codable {
//    func roundDouble(d: Double) -> Double {
//        return Double(round(10 * d)/10)
//    }
    
    var swellSize: Double
    var windDirection: String
    var swellPeriod: Double
    var windSpeed: Double
    var waveEnergy: Double
    var waveForm: String
    var formColor: String
    var time: String?
    
    // Method to round all Double variables
//        mutating func roundDoubles() {
//            swellSize = round(10 * swellSize) / 10
//            swellPeriod = round(10 * swellPeriod) / 10
//            windSpeed = round(10 * windSpeed) / 10
//            waveEnergy = round(10 * waveEnergy) / 10
//        }
    //or could just round this when we call them in the view, may be easier!
    func distance(to other: WaveStats) -> Double {
            let swellSizeDiff = abs(self.swellSize - other.swellSize)
            let swellPeriodDiff = abs(self.swellPeriod - other.swellPeriod)
            let windSpeedDiff = abs(self.windSpeed - other.windSpeed)
            let gnarlyRatingDiff = abs(self.gnarlyRating - 10)
            
        //have small logic to calculate the form?
        // have enum for forms but for this instance
        // hardcoded no continuiety
        let form = (self.waveForm == "Glass" || self.waveForm == "Offshore") ? 0.0: 100.0
        
        
            // Sum the differences lowest is chosen
        return swellSizeDiff + swellPeriodDiff + windSpeedDiff + Double(gnarlyRatingDiff) + form
        
        }
    
    var gnarlyRating: Int {
        let targetHeight: Double = 4.5 //max4
        let targetAllowance: Double = 1.5 //max4
        let targetPeriod: Double = 15.0 //max3
        let targetForm: String = "Glass" //max4
        let windAllowance: Int = 6
        
        var rating: Int = 0;
        
        if(Int(windSpeed) < windAllowance) {
            rating += 2
        }
        else if(Int(windSpeed) < (windAllowance * 2)) {
            rating += 1
        }
        else if(Int(windSpeed) > (windAllowance * 4)) {
            rating -= 2
        }
        else if(Int(windSpeed) > (windAllowance * 3)) {
            rating -= 1
        }
        
        //rate swell height
        if(swellSize < (targetHeight+targetAllowance) && swellSize > (targetHeight-targetAllowance)) {
            rating += 4
        }
        else if(swellSize > (targetHeight+targetAllowance) && swellSize < 7.0) {
            rating += 3
        }
        else if(swellSize > 7.0) {
            rating += 1
        }
        //maybe change this?
        else if (swellSize <= (targetHeight-targetAllowance) && swellSize > 2.0){
            rating += 1
        }
        else {
            rating -= 2
        }
        
        //rate wavePeriod
        //15.0
        if(swellPeriod > targetPeriod) {
            rating += 3
        }
        else if(swellPeriod > (targetPeriod-targetAllowance)) {
            rating += 2
        }
        else if(swellPeriod > 10) {
            rating += 1
        }
        else {
            rating -= 4
        }
        
        //rate form
        
        if(waveForm==targetForm) {
            rating += 4
        }
        else if(waveForm=="Offshore") {
            rating += 3
        }
        else {
            rating -= 6
        }
        
        if rating < 0 {
            return 0
        }
        
        return rating
        
    }
}



struct BeachCardExperiment: View {
    
    //init vars of card and beach
    @Binding var beachStats: BeachStats
    @Binding var waves: Initial
    
    @StateObject var waveModel = WaveModel()
    
    @State private var waveData: [WaveStats]
    
    @State private var cardSpacing: Double
    
    //Initialise and create Wave Model
    init(beachStats: Binding<BeachStats>, waves: Binding<Initial>) {
        _beachStats = beachStats
        _waves = waves
        
        time = Time(dayTime: Array(repeating: DayTime(day: "penis", time: Array(repeating: "penis", count: 24)), count: 7))
        
        
        waveData = Array(repeating: WaveStats(swellSize: 0.0, windDirection: "Default", swellPeriod: 0.0, windSpeed: 0.0, waveEnergy: 0.0, waveForm: "Default", formColor: "Color-Default"), count: 168)
        
        cardSpacing = beachStats.minimize.wrappedValue ? 2.0 : 20.0
        
        
        
    }
    
    //based off of waveTime and day in appear method
    @State var timeSelector: Int = 0
    
    @State private var waveTime: Int = 0 //pass these in to show current time
    @State private var day: Int = 0 //0-6 starting from current da-date to 7
    
    @State private var timeClock: String = "Default"
    @State private var dateClock: String = "Default"
    @State private var dateDay: String = "Default"
    @State private var time: Time
    @State private var showTodayMessage: Bool = false
    @State private var requests: Int = 0
    @State private var attributeShowing: Bool = true
    @State private var loading: Bool = true
    
    func mapWaveStats(waves: Initial, index: Int = 0, stats: [WaveStats] = Array(repeating: WaveStats(swellSize: 0.0, windDirection: "Default", swellPeriod: 0.0, windSpeed: 0.0, waveEnergy: 0.0, waveForm: "Default", formColor: "Color-Default"), count: 168)) -> [WaveStats] {
        
        var updatedStats = stats
        
        guard index < waves.hours.count else {
            // All data fetched, update UI if necessary
            return updatedStats
        }
        
        // Ensure waves.hours[index] is within bounds
          guard index >= 0 && index < updatedStats.count else {
              // Return the updated stats as is if the index is out of bounds
              return updatedStats
          }
        
        //update waveStats

        updatedStats[index].swellPeriod = waveModel.roundDouble(d: waves.hours[index].wavePeriod.noaa ?? 0.069)
        
        updatedStats[index].waveEnergy = waveModel.waveEnergy(swellHeight: waveModel.SwellHeightProviderAverage(stat: waves.hours[index].swellHeight, inM: true), swellPeriod: updatedStats[index].swellPeriod)
        
        updatedStats[index].swellSize =  waveModel.SwellHeightProviderAverage(stat: waves.hours[index].swellHeight, inM: false)
        
        updatedStats[index].windSpeed = waveModel.mToMph(m: waveModel.WindProviderAverage(stat: waves.hours[index].windSpeed))
        
        let windDirectionDegree = waveModel.WindProviderAverage(stat: waves.hours[index].windDirection)
        
        updatedStats[index].windDirection = waveModel.degreeToCardinal(degree: windDirectionDegree)
        
        //beach target should be good?
        updatedStats[index].waveForm = waveModel.BeachDirection(dir: windDirectionDegree, target: beachStats.beachTarget)
        
        updatedStats[index].formColor = waveModel.UpdateColourBasedOnForm(form: updatedStats[index].waveForm)
        
        
        // Recursive call to process the next index
        return mapWaveStats(waves: waves, index: index + 1, stats: updatedStats)
    }

    func activateAPI ()  {
        beachStats.allowApi = true
        print("setting allow api to be true")
    }
    
    func goToToday() {
        self.waveTime = 0
        self.day = 0
        
        withAnimation {
            self.showTodayMessage = true //show today message
        }
        
        self.updateTime()
    }
    
    func updateDay(isRight: Bool) {
        let sub: Int = isRight ? 1 : -1
        var tempDay = self.day + sub
        
        
        if(tempDay > 6) {
            tempDay = 0
        }
        
        if(tempDay < 0) {
            tempDay = 6
        }

        self.day = tempDay
        //update time
        self.updateTime()
    }
    
    func updateTime() {
        time =  waveModel.mapTime(data: self.waves)
        
        timeSelector = waveModel.TimeSelector(hours: waveTime, days: day)

        //create requests
        self.requests = self.waves.meta.requestCount
        
        self.timeClock = self.waveModel.mapWaveTimeToString(time: time.dayTime[self.day].time[waveTime])
        
        self.dateClock = self.waveModel.mapWaveDateToString(time: time.dayTime[self.day].day)
        
        self.dateDay = self.waveModel.mapDateToDayLiteral(time: time.dayTime[self.day].day)
        
    }
    
    var body: some View {
        
            ZStack {
                if beachStats.minimize == false {
                    Color("Color-Pastel-Main").ignoresSafeArea()
                }
                VStack {
                    if(loading && beachStats.minimize == false) {
                        LoadingView()
                        
                    }
                    else {
                    VStack (alignment: .leading) {
                        //title
                        HStack {
                            Text(self.beachStats.townName).italic().foregroundColor(.black)
                                .scaledToFill().font(.title)
                            Spacer()
                            //should take this from time data
                            //current data associated with wave time
                            if(!beachStats.minimize) {
                                Button(action: {updateDay(isRight: false)}) {
                                    Image.init(systemName: "arrow.left")
                                }.hoverEffect(.lift)
                                VStack {
                                    let today: String = self.day == 0 ? " (today)" : ""
                                    Text(self.dateDay + today).font(.footnote).foregroundStyle(.gray)
                                    Text(self.dateClock).font(.title3)
                                }
                                Button(action: {updateDay(isRight: true)}) {
                                    Image(systemName: "arrow.right")
                                }.padding(0)
                            }
                        }.foregroundColor(.black)
                        
                        VStack (alignment: .leading, spacing: self.cardSpacing) {
                            //image - feature request - cycle through api of east strand pictures? - after I configure API and other features
                            if(!beachStats.minimize) {
                                Image(beachStats.beachName)
                                    .resizable()
                                    .cornerRadius(10.0)
                                    .aspectRatio(contentMode: .fit)
                                    .padding(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/).transition(.scale)
                            }
                            //api of surf images?
                            
                            HStack {
                                Button(action: goToToday) {
                                    if(!showTodayMessage) {
                                        Text(beachStats.beachName)
                                            .italic()
                                            .fontWeight(.semibold)
                                            .font(.system(size: 25))
                                            .underline()
                                            .padding(.bottom, 1.0)
                                            .foregroundColor(.black).transition(.scale)
                                    }
                                }
                                VStack {
                                    if showTodayMessage {
                                        Text("Here's Todays forecast").italic()
                                            .fontWeight(.semibold)
                                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                            .underline()
                                            .padding(.bottom, 1.0)
                                            .foregroundColor(Color(self.waveData[timeSelector].formColor)).onAppear {
                                                
                                                // Use a timer to hide the text after 1 second
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    withAnimation {
                                                        self.showTodayMessage = false}
                                                }
                                            }.transition(.scaleAndSlide)
                                    }
                                }
                            }.onAppear {
                                //init beach stats
                                self.waveData = MappingData().mapWaveStats(waves: self.waves, beachTarget: self.beachStats.beachTarget)
                                updateTime()
            
                            }
                            HStack(alignment: .center, spacing: 6) {
                                
                                VStack(alignment: .leading, spacing: 6) { //right allign
                                    
                                    if(!beachStats.minimize) {
                                        WaveHorizontalView(waveStats: $waveData, day: $timeSelector)
                                    } else {
                                       // HighlightWaveView(waveStats: $waveData, preference: nil)
                                    }
                                }
                            }
                            HStack {
                                Text(String(self.requests) + "/10")
                                Spacer()
                                Button(action: activateAPI) {
                                    Image.init(systemName: "figure.surfing")
                                }.hoverEffect(.lift)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Rectangle().foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 15))
                    .padding().gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                        .onEnded { value in
                            
                            withAnimation(.linear(duration: 0.8)) {
                                if (value.translation.height >= 70 || value.translation.height <= -70 ) {
                                    
                                    if(beachStats.minimize) {
                                        
                                        self.cardSpacing = 20.0
                                        self.attributeShowing = false
                                        beachStats.minimize = false
                                        print("minimize should be false")
                                    } else {
                                        
                                        self.cardSpacing = 2.0
                                        self.attributeShowing = true
                                        beachStats.minimize = true
                                        print("minimize should be true")
                                    }
                                }
                            }
                        })
                }
                
            }
            
        }.onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                self.loading = false
                //self.updateTime()
            }
        }
    }
   
}

//do this to preview with a bind
struct BeachCardExperimentPreview : PreviewProvider {
    
    @State static var beachStats =  BeachStats(allowApi: false, minimize: false, townName: "Portrush", beachName: "East Strand", beachTarget: 236.0, beachDbName: "EastStrandData", lat: "55.206784",lng: "-6.64602")
    
    @State static var dummy = GetDummy.dummyInitial
    //dummy to replace
//    @State static var dummy = Initial(hours: Array(repeating: Wave(swellHeight: WaveAPIProviders(noaa: 0.69, sg: 0.69, icon: 0.69, dwd: 0.69), wavePeriod: WaveAPIProviders(noaa: 0.69, sg: 0.69, icon: 0.69, dwd: 0.69), windDirection: WaveAPIProviders(noaa: 0.69, sg: 0.69, icon: 0.69, dwd: 0.69), windSpeed: WaveAPIProviders(noaa: 0.69, sg: 0.69, icon: 0.69, dwd: 0.69), time: "2024-01-02T21:00:00+00:00"), count: 168), meta: RequestCount(requestCount: 0))

    static var previews: some View {
        BeachCardExperiment(beachStats: $beachStats, waves: $dummy)
        
    }
}
