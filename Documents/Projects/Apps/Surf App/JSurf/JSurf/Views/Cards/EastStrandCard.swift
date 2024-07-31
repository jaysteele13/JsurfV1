//import Foundation
//
//import SwiftUI
////if home flag is true minimize screen up take out wave pic and api deets
//
//struct EastStrandCard: View {
//    
//    
//    //create instance of API call
//    @StateObject var waveModel = WaveModel()
//    //based off of waveTime and day in appear method
//    @State var timeSelector: Int = 0
//    @Binding var minimize: Bool
//    @State private var cardSpacing: Double = 20.0 //always start 20
//    
//    @State private var waveTime: Int = 0 //pass these in to show current time
//    @State private var day: Int = 0 //0-6 starting from current da-date to 7
//        
//    //wave vars
//    @State private var swellSize: Double = 69.0
//    @State private var swellPeriod: Double = 69.0
//    @State private var windDirectionDegree: Double = 0.0
//    @State private var windDirection: String = "Default"
//    @State private var waveForm: String = "Default"
//    @State private var formColor: String = "Color-Default"
//    @State private var timeClock: String = "Default"
//    @State private var dateClock: String = "Default"
//    @State private var dateDay: String = "Default"
//    @State private var gnarlyRating: Int = 0
//    @State private var gnarlyWarning: Bool = false //configured a flag which will change ui if wave are too powerful!
//    @State private var gnarlyRisk: Double = 2500
//    @State private var showTodayMessage: Bool = false
//    @State private var waveEnergy: Double = 0.0
//    
//    @State private var attributeShowing: Bool = true
//    
//    
//    //vars for gnarly rating
//    var offStar: Image?
//    var onStar = Image(systemName: "star.fill")
//    
//    let starOffColor = Color.gray
//    let starOnColor = Color("Color-Pastel-Blue")
//    
//    func populateGnarly (for number: Int) -> Image {
//        if number > self.gnarlyRating {
//            self.offStar ?? self.onStar
//        }
//        else
//        {
//            self.onStar
//        }
//    }
//
//    func activateAPI ()  {
//        waveModel.allowApi = true
//        waveModel.fetch()
//    }
//    
//    func goToToday() {
//        self.waveTime = 0
//        self.day = 0
//        
//        withAnimation {
//            self.showTodayMessage = true //show today message
//        }
//        
//        self.changeTime()
//    }
//    
//    func updateDay(isRight: Bool) {
//        let sub: Int = isRight ? 1 : -1
//        var tempDay = self.day + sub
//        
//        
//        if(tempDay > 6) {
//            tempDay = 0
//        }
//        
//        if(tempDay < 0) {
//            tempDay = 6
//        }
//
//        
//        self.day = tempDay
//        //update time
//        self.changeTime()
//    }
//    
//    func updateWaveDay(isRight: Bool) {
//        
//        //+3 hours
//        let sub: Int = isRight ? 3 : -3
//        var tempTime = self.waveTime + sub
//        var tempDay = self.day
//        
//        
//        //0
//        //if is right and day is 6 - go back to the start
//        if(tempTime > 23) {
//            //temptime - 23 = new tempTime
//            tempTime = 0
//            if(tempDay+1 > 6) {
//                tempDay = 0
//            }
//            else {
//                tempDay += 1
//            }
//        }
//        
//        if(tempTime < 0) {
//            //temptime - 23 = new tempTime
//            tempTime = 21
//            if(tempDay-1 < 0) {
//                tempDay = 6
//            }
//            else {
//                tempDay -= 1
//            }
//        }
//        
//        //changes the times lol
//        self.waveTime = tempTime
//        self.day = tempDay
//        //update time
//        self.changeTime()
//    }
//    
//    func changeTime() {
//        //change vars
//        timeSelector = waveModel.TimeSelector(hours: self.waveTime, days: self.day)
//
//        //make these work - why don't they work!?! check again later!?
//        self.swellPeriod = waveModel.roundDouble(d: waveModel.waves.hours[timeSelector].wavePeriod.noaa ?? 0.069)
//        
//        self.waveEnergy = waveModel.waveEnergy(swellHeight: waveModel.SwellHeightProviderAverage(stat: waveModel.waves.hours[timeSelector].swellHeight, inM: true), swellPeriod: self.swellPeriod)
//        
//        self.swellSize =  waveModel.SwellHeightProviderAverage(stat: waveModel.waves.hours[timeSelector].swellHeight, inM: false)
//        
//        self.windDirectionDegree = waveModel.WindDirectionProviderAverage(stat: waveModel.waves.hours[timeSelector].windDirection)
//        
//        self.windDirection = waveModel.degreeToCardinal(degree: self.windDirectionDegree)
//        
//        self.waveForm = waveModel.BeachDirection(dir: self.windDirectionDegree, target: waveModel.beachTarget)
//        
//        self.formColor = waveModel.UpdateColourBasedOnForm(form: waveModel.BeachDirection(dir: waveModel.WindDirectionProviderAverage(stat: waveModel.waves.hours[timeSelector].windDirection), target: waveModel.beachTarget))
//        
//        self.timeClock = self.waveModel.mapWaveTimeToString(time: waveModel.waveTime.dayTime[self.day].time[waveTime])
//        
//        self.dateClock = self.waveModel.mapWaveDateToString(time: waveModel.waveTime.dayTime[self.day].day)
//        
//        self.dateDay = self.waveModel.mapDateToDayLiteral(time: waveModel.waveTime.dayTime[self.day].day)
//        
//        self.gnarlyRating = self.waveModel.gnarlyRating(swellHeight: self.swellSize, wavePeriod: self.swellPeriod, waveForm: self.waveForm)
//        
//        if(self.waveEnergy > self.gnarlyRisk) {
//            self.gnarlyWarning = true
//        }
//        else {
//            self.gnarlyWarning = false
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            Color(self.formColor).ignoresSafeArea()
//            VStack {
//                VStack (alignment: .leading) {
//                    //title
//                    HStack {
//                        Text("Portrush").italic().font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).foregroundColor(.black)
//                            .scaledToFill()
//                        Spacer()
//                        //should take this from time data
//                        //current data associated with wave time
//                        Button(action: {updateDay(isRight: false)}) {
//                            Image.init(systemName: "arrow.left")
//                        }.hoverEffect(.lift)
//                        VStack {
//                            let today: String = self.day == 0 ? " (today)" : ""
//                            Text(self.dateDay + today).font(.footnote).foregroundStyle(.gray)
//                            Text(self.dateClock).font(.title3)
//                        }
//                        Button(action: {updateDay(isRight: true)}) {
//                            Image(systemName: "arrow.right")
//                        }.padding(0)
//                        
//                    }.foregroundColor(.black)
//                    
//                    //current wave time
//                    //replace with this
//                    HStack {
//                        Button(action: {updateWaveDay(isRight: false)}) {
//                            Image.init(systemName: "arrow.left")
//                        }.hoverEffect(.lift)
//                        Text(self.timeClock)
//                        Button(action: {updateWaveDay(isRight: true)}) {
//                            Image(systemName: "arrow.right")
//                        }
//                        .hoverEffect(.lift)
//                    }.foregroundColor(.gray)
//                    
//                    VStack (alignment: .leading, spacing: self.cardSpacing) {
//                        //image - feature request - cycle through api of east strand pictures? - after I configure API and other features
//                        if(!minimize) {
//                            Image("EastStrand")
//                                .resizable()
//                                .cornerRadius(10.0)
//                                .aspectRatio(contentMode: .fit)
//                                .padding(/*@START_MENU_TOKEN@*/.vertical/*@END_MENU_TOKEN@*/).transition(.scale)
//                        }
//                        //api of surf images?
//                        
//                        HStack {
//                            Button(action: goToToday) {
//                                if(!showTodayMessage) {
//                                    Text("East Strand")
//                                        .italic()
//                                        .fontWeight(.semibold)
//                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                                        .underline()
//                                        .padding(.bottom, 1.0)
//                                        .foregroundColor(.black).transition(.scale)
//                                }
//                            }
//                            VStack {
//                                //show Today briefly
//                                
//                                if showTodayMessage {
//                                    Text("Here's Todays forecast").italic()
//                                        .fontWeight(.semibold)
//                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                                        .underline()
//                                        .padding(.bottom, 1.0)
//                                        .foregroundColor(Color(self.formColor)).onAppear {
//                                            
//                                            // Use a timer to hide the text after 1 second
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                                withAnimation {
//                                                    self.showTodayMessage = false}
//                                            }
//                                        }.transition(.scale)
//                                }
//                            }
//                            Spacer()
//                            //stars and text
//                            
//                            VStack {
//                                //stars
//                                Text(gnarlyWarning ? "Gnarly Risk ⚠️"  : "Gnarly Rating 🏄" ).foregroundStyle(self.starOnColor).font(gnarlyWarning ? .title3 : .subheadline).bold()
//                                
//                                HStack{
//                                    
//                                    
//                                    //Divide by 2 currently so technically out of 5 rather than 10.
//                                    if(!gnarlyWarning) {
//                                        ForEach(1..<6, id:\.self) { number in
//                                            populateGnarly(for: number).foregroundStyle(number > self.gnarlyRating/2 ? self.starOffColor : self.starOnColor)
//                                            
//                                        }
//                                    }
//                                    
//                                }
//                                // have a feature to create stars (or wave emojis) based on my preffered conditions.
//                            }.font(.callout)
//                            
//                        }.onAppear {
//                            timeSelector = waveModel.TimeSelector(hours: waveTime, days: day)
//                            
//                            
//                            waveModel.fetch()
//                            
//                            
//                            self.swellPeriod = waveModel.roundDouble(d: waveModel.waves.hours[timeSelector].wavePeriod.noaa ?? 0.069)
//                            
//                            //                        get wave energy when wave height is in meters
//                            self.waveEnergy = waveModel.waveEnergy(swellHeight: waveModel.SwellHeightProviderAverage(stat: waveModel.waves.hours[timeSelector].swellHeight, inM: true), swellPeriod: self.swellPeriod)
//                            
//                            self.swellSize =  waveModel.SwellHeightProviderAverage(stat: waveModel.waves.hours[timeSelector].swellHeight, inM: false)
//                            
//                            
//                            self.windDirectionDegree = waveModel.WindDirectionProviderAverage(stat: waveModel.waves.hours[timeSelector].windDirection)
//                            
//                            self.windDirection = waveModel.degreeToCardinal(degree: self.windDirectionDegree)
//                            
//                            self.waveForm = waveModel.BeachDirection(dir: self.windDirectionDegree, target: waveModel.beachTarget)
//                            
//                            self.formColor = waveModel.UpdateColourBasedOnForm(form: waveModel.BeachDirection(dir: waveModel.WindDirectionProviderAverage(stat: waveModel.waves.hours[timeSelector].windDirection), target: waveModel.beachTarget))
//                            
//                            self.timeClock = self.waveModel.mapWaveTimeToString(time: waveModel.waveTime.dayTime[self.day].time[waveTime])
//                            
//                            self.dateClock = self.waveModel.mapWaveDateToString(time: waveModel.waveTime.dayTime[self.day].day)
//                            
//                            self.dateDay = self.waveModel.mapDateToDayLiteral(time: waveModel.waveTime.dayTime[self.day].day)
//                            
//                            self.gnarlyRating = self.waveModel.gnarlyRating(swellHeight: self.swellSize, wavePeriod: self.swellPeriod, waveForm: self.waveForm)
//                            
//                            if(self.waveEnergy > self.gnarlyRisk) {
//                                self.gnarlyWarning = true
//                            }
//                            else {
//                                self.gnarlyWarning = false
//                            }
//                            
//                        }
//                        HStack(alignment: .center, spacing: 6) {
//                            
//                            VStack(alignment: .leading, spacing: 6) { //right allign
//                                
//                                if(!minimize) {
//                                    
//                                    HStack {
//                                        Text("Swell Size: ").bold().italic()
//                                        Image(systemName: "arrow.right")
//                                        //swell size
//                                        
//                                        //find a way to make these look neater
//                                        Text(String(self.swellSize)+"ft")
//                                    }.foregroundColor(self.attributeShowing ?.black : .white).transition(AnyTransition.scaleAndSlide)
//                                    HStack {
//                                        Text("Wave Period: ").bold().italic()
//                                        Image(systemName: "arrow.right")
//                                        //wave period
//                                        Text(String(self.swellPeriod)+"s")
//                                    }.foregroundColor(self.attributeShowing ?.black : .white).transition(AnyTransition.scaleAndSlide)
//                                    HStack {
//                                        Text("Wind Direction: ").bold().italic()
//                                        Image(systemName: "arrow.right")
//                                        //wind direction
//                                        Text(self.windDirection)
//                                        
//                                    }.foregroundColor(self.attributeShowing ?.black : .white).transition(AnyTransition.scaleAndSlide)
//                                    
//                                    HStack {
//                                        Text("Wave Energy (kj):").bold().italic()
//                                        Image(systemName: "arrow.right")
//                                        //wind direction
//                                        Text(String(format: "%g", self.waveEnergy))
//                                        
//                                    }.foregroundColor(self.attributeShowing ?.black : .white).transition(AnyTransition.scaleAndSlide)
//                                }
//                                //on or offshore?
//                                Text(self.waveForm)
//                                    .foregroundColor(Color(self.formColor)).bold().fontWeight(.heavy).font(.system(size: 24))
//                            }
//                        }
//                        //surf symbol
//                        HStack {
//                            Text(String(waveModel.requests) + "/10")
//                            Spacer()
//                            Button(action: activateAPI) {
//                                Image.init(systemName: "figure.surfing")
//                            }.hoverEffect(.lift)
//                            
//                            
//                            
//                        }
//                        .foregroundColor(.gray)
//                    }
//                    
//                    
//                    
//                }
//                .padding()
//                .background(Rectangle().foregroundColor(.white)
//                    .cornerRadius(15)
//                    .shadow(radius: 15))
//                .padding().gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
//                    .onEnded { value in
//                        
//                        withAnimation {
//                            if (value.translation.width >= -100 && value.translation.width <= 100) ||
//                                (value.translation.height >= 0) {
//                                self.cardSpacing = minimize ? 20.0 : 2.0 // opposites
//                                self.minimize.toggle()
//                                self.attributeShowing.toggle()
//                                
//                                
//
//                            }
//                        }
//                    })
//                //cheaty way to push view on top
//                if self.minimize {
//                    Spacer()
//                }
//            }
//            
//        }
//      
//    }
//   
//}
//
////#Preview {
////    EastStrandCard()
////}
//
////do this to preview with a bind
//struct EastStrandCardPreview : PreviewProvider {
//
//    @State static var minimize = false
//
//    static var previews: some View {
//        EastStrandCard(minimize: $minimize)
//    }
//
//}
