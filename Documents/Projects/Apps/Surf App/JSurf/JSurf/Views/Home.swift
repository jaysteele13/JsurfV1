//
//  Home.swift
//  JSurf
//
//  Created by Jay Steele on 26/12/2023.
//


import SwiftUI
import Foundation


struct BeachStats: Hashable, Codable {
    var allowApi: Bool
    var minimize: Bool //maybe change this to no be an array
    var townName: String
    var beachName: String
    var beachTarget: Double
    var beachDbName: String
    var lat: String
    var lng: String
}

//Define Beaches here
class BeachesViewModel: ObservableObject {
    @Published var beaches: [BeachStats]
    @Published var beachData: [Initial]
    
    //Important Dictionary
    //0 - East Strand
    //1 - West Strand
    //2 - White Rocks
    
    //EAST STRAND
    @State private var eastStrand = BeachStats(allowApi: false, minimize: true, townName: "Portrush", beachName: "East Strand", beachTarget: 219.0, beachDbName: "EastStrandData", lat: "55.206784",lng: "-6.64602")
    
    //WEST STRAND //guessed target
    @State private var westStrand = BeachStats(allowApi: false, minimize: true, townName: "Portrush", beachName: "West Strand", beachTarget: 137.0, beachDbName: "WestStrandData", lat: "55.199955",lng: "-6.659712")
    
    //White Rocks  //guessed target
    @State private var whiteRocks = BeachStats(allowApi: false, minimize: true, townName: "Portrush", beachName: "White Rocks", beachTarget: 180.0, beachDbName: "WhiteRocksData", lat: "55.207734",lng: "-6.612517")
    
    
    
    init() {
        //update this variable with how many beaches i have
        let beachCount = 3
        
        
        //default values
        let requestCount = RequestCount(requestCount: 0)
        //init wave
        // Initialize WaveAPIProviders objects
        let waveProvider1 = WaveAPIProviders(noaa: 3.69, sg: 0.69, icon: 0.69, dwd: 0.69)
        let waveProvider2 = WaveAPIProviders(noaa: 0.69, sg: 0.69, icon: 0.69, dwd: 0.69)
        
        //IMPORTANT CHANGE COUNT TO MATCH VAR maxDataCap AT ALL TIMES must 168!!!
        self.beachData = Array(repeating: Initial(hours: Array(repeating: Wave(swellHeight: waveProvider2, wavePeriod: waveProvider2, windDirection: waveProvider1, windSpeed: waveProvider1, time:  "2024-01-02T21:00:00+00:00"), count: 168), meta: requestCount), count: beachCount)
         
        self.beaches = Array(repeating: BeachStats(allowApi: false, minimize: true, townName: "Default", beachName: "Default", beachTarget: 236.0, beachDbName: "Default", lat: "10.1234",lng: "20.5678"), count: beachCount)
        // Initialize beaches array with default values or any initial data
        self.beaches =  [eastStrand, westStrand, whiteRocks]
        
    }
}

struct Home: View {

    
    @StateObject var beachModel = BeachesViewModel()
    
    @StateObject var waveModel = WaveModel() //give fetch the parameters
    
    @StateObject var dailyRequest = DailyRequests()
    
    @State private var loading: Bool = true
    
    @State private var today: String = "Dk mate"
    
    func fetchBeachData(index: Int, recursion: Bool, api: Bool = false) {
        guard index < beachModel.beaches.count else {
            // All data fetched, update UI if necessary
            return
        }

        if api {
            beachModel.beaches[index].allowApi = true;
        }
        
        let beach = beachModel.beaches[index]
        //assign variables to fetch here
        
        //fetch is doing the wrong thing. retrieving old data
        print("here is beach api value: \(beach.allowApi)")
     
        
    
        waveModel.fetch(allowApi: beach.allowApi, beachTarget: beach.beachTarget, dbName: beach.beachDbName, lat: beach.lat, lng: beach.lng) { waveData in
            // Handle the retrieved waveData here
            if let waveData = waveData {
                beachModel.beachData[index] = waveData
            } else {
                print("Error fetching wave data for beach at index \(index)")
            }
            //could also add the request number to a cahce system to know how many times the api has been hit
        }
        
        beachModel.beaches[index].allowApi = false;

        if(recursion) {
            // Throttle requests by introducing a delay
            fetchBeachData(index: index + 1, recursion: recursion, api: api)
        }
    }
    
  
    var body: some View {
        
        ZStack {
            
            Color("Color-Pastel-Main").ignoresSafeArea()
            VStack {
                if(loading) {
                    LoadingView()
                }
                
                //bario font
                //Text(self.today).font(.custom("Barrio-Regular", size: 30))
                //Text(self.today).font(.title) //regular font
                
                
                if beachModel.beaches.allSatisfy({ $0.minimize }) {
                    Text(self.today).font(.custom("Barrio-Regular", size: 30))
                    ForEach(beachModel.beaches.indices, id: \.self) { index in
                        
                        BeachCardExperiment(beachStats: $beachModel.beaches[index],waves: $beachModel.beachData[index]).allowsHitTesting(!loading)
                        
                        
                    }
                } else {
                    // Show only the first false beach 
                    if let index = beachModel.beaches.firstIndex(where: { !$0.minimize }) {
                            BeachCardExperiment(beachStats:  $beachModel.beaches[index], waves: $beachModel.beachData[index]).allowsHitTesting(!loading)
                    }
                }
                
                Spacer() // Keep Views at the top
            }.onReceive(beachModel.$beaches) { _ in
                //check if request allowed
                if let index = beachModel.beaches.firstIndex(where: { $0.allowApi }) {
                    print("\(beachModel.beaches[index].beachName) is updating their api")
                    
                    fetchBeachData(index: index, recursion: false)
                }
                
                
                if beachModel.beaches.allSatisfy({ $0.minimize }) {
                    self.loading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.loading = false
                    }
                }
            }
        }.onAppear {
            //put this in a more neat function
            var isToday = dailyRequest.isNewDay()
            
            //this does requests once a day!
            if (!isToday) {
                dailyRequest.setLastHit(hit: 0)
                print("set hit to 0 -> ", String(dailyRequest.getLastHit()))
                dailyRequest.setLastDay() //set the day incase
                isToday = dailyRequest.isNewDay()
            }
            
            //check request number (if above)
            let isHit = dailyRequest.getLastHit()
            
            //isToday = false //uncomment this line to allow new requests each day
                         
            if(isToday && isHit == 0) {
                //enable api here -> works with optional param
                fetchBeachData(index: 0, recursion: true, api: true)
                dailyRequest.setLastHit(hit: isHit+1)
                print("hit all beach API's")
            }
            fetchBeachData(index: 0, recursion: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loading = false
            }
            
            print("here is hit count: ", String(dailyRequest.getLastHit()))
            
            //after this set the last day on appear into cache (current when thread ran)
            dailyRequest.setLastDay() //set the day
            self.today = waveModel.mapDateToDayLiteral(time:  dailyRequest.getLastDay()!) //could caue a crash
            
            //delete white rocks
            //waveModel.deleteFile(fileName: "WhiteRocksData")
        }
        
    }
    
}

#Preview {
    Home()
}
