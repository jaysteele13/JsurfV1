import Foundation
import SwiftUI

//change extenaion in anim file
extension AnyTransition {static var scaleAndSlide: AnyTransition {
     AnyTransition.scale.combined(with: .slide)
  }
}


//JSON Model
struct Initial: Hashable, Codable {
    let hours: [Wave] //maybe change this to no be an array
    let meta: RequestCount
}


struct RequestCount: Hashable, Codable {
    //Structure of json with params
    let requestCount: Int
}

struct Wave: Hashable, Codable {
    //Structure of json with params
    let swellHeight: WaveAPIProviders
    let wavePeriod: WaveAPIProviders
    let windDirection: WaveAPIProviders
    let windSpeed: WaveAPIProviders
    let time: String
}

struct WaveAPIProviders: Hashable, Codable {
    let noaa: Double?
    let sg: Double?
    let icon: Double?
    let dwd: Double?
}

//Additional Structs

//here I will make a time variable that will holds two arrays, one for days and one for 24 hour time

struct Time: Hashable, Codable {
    var dayTime: [DayTime]
}

struct DayTime: Hashable, Codable {
    var day: String
    var time: [String]
}

//should have a constructor to set the lat, lng and params per beach as well as target also have a temp db name for example the current one is called ""
public class WaveModel: ObservableObject {
    @Published var waves: Initial
    @Published var maxDataCap: Int = 168 //one week for showing days
    
    init() {

        
        let requestCount = RequestCount(requestCount: 0)
        //init wave
        // Initialize WaveAPIProviders objects
        let waveProvider1 = WaveAPIProviders(noaa: 3.69, sg: 0.69, icon: 0.69, dwd: 0.69)
        let waveProvider2 = WaveAPIProviders(noaa: 0.69, sg: 0.69, icon: 0.69, dwd: 0.69)
        
        //IMPORTANT CHANGE COUNT TO MATCH VAR maxDataCap AT ALL TIMES
        self.waves = Initial(hours: Array(repeating: Wave(swellHeight: waveProvider2, wavePeriod: waveProvider2, windDirection: waveProvider1, windSpeed: waveProvider1, time: "2024-01-02T21:00:00+00:00"), count: 168), meta: requestCount)
        
        
        
    }
    
    func roundDouble(d: Double) -> Double {
        return Double(round(10 * d)/10)
    }
    
    func mToFt(meter: Double) -> Double {
        
        var ft: Double = meter * 3.28084
        //put to first decimal place
        ft = Double(round(10 * ft)/10)
        
        return ft
    }
    
    func ftToM(ft: Double) -> Double {
        
        var meter: Double = ft * 0.3048
        //put to first decimal place
        meter = Double(round(10 * meter)/10)
        
        return meter
    }
    
    func mToMph(m: Double) -> Double {
        var mph = m * 2.236936
        
        mph = Double(round(1 * mph)/1)
        return mph //round
        
    }
    
//    func degreeToCardinal(degree: Double) -> String {
//        let normalizedDegree = degree.truncatingRemainder(dividingBy: 360)
//        let val: Int = Int(((normalizedDegree / 22.5)));
//        let arr: [String] = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
//        return arr[(val % 16)];
//    }

    func degreeToCardinal(degree: Double) -> String {
        let normalizedDegree = degree.truncatingRemainder(dividingBy: 360)

        switch normalizedDegree {
        case 348.75...360, 0..<11.25:
            return "N"
        case 11.25..<33.75:
            return "NNE"
        case 33.75..<56.25:
            return "NE"
        case 56.25..<78.75:
            return "ENE"
        case 78.75..<101.25:
            return "E"
        case 101.25..<123.75:
            return "ESE"
        case 123.75..<146.25:
            return "SE"
        case 146.25..<168.75:
            return "SSE"
        case 168.75..<191.25:
            return "S"
        case 191.25..<213.75:
            return "SSW"
        case 213.75..<236.25:
            return "SW"
        case 236.25..<258.75:
            return "WSW"
        case 258.75..<281.25:
            return "W"
        case 281.25..<303.75:
            return "WNW"
        case 303.75..<326.25:
            return "NW"
        case 326.25..<348.75:
            return "NNW"
        default:
            return "Unknown"
        }
    }


    
    func waveEnergy(swellHeight: Double, swellPeriod: Double) -> Double {
        let p: Double = 1000.0
        let g: Double = 9.81
        //let h2: Double = swellHeight * swellHeight//should just be wellHeight Squared ! *
        
        let waveLength: Double = (g*(swellPeriod * swellPeriod * swellPeriod)) / (2.0 * Double.pi)
        let c: Double = waveLength / swellPeriod //c is wave speed
        let e: Double = (0.125 * p * g * swellHeight)/10 //either .5 (1/2) or .125 (1/8)
        let f = 1/swellPeriod
        let pFlux = f * e
        var power = pFlux * c
        
        //round power and guess work to make wave energy match surf-forecast
        // power = (power * 45) // seems to match closer to other forecasts
        
//        let divertPower: Double = 5500.0
//        
//        if(power > divertPower) {
//            power = (power - (power * 0.4))
//        }
        power = power * 0.125
        
        return Double(round(1 * power)/1)
    }
    
    
    //based off my perference
    func gnarlyRating(swellHeight: Double, wavePeriod: Double, waveForm: String, windSpeed: Double) -> Int {
        //tacky if statements
        
        //returning a number out of 10
        
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
        if(swellHeight < (targetHeight+targetAllowance) && swellHeight > (targetHeight-targetAllowance)) {
            rating += 4
        }
        else if(swellHeight > (targetHeight+targetAllowance) && swellHeight < 7.0) {
            rating += 3
        }
        else if(swellHeight > 7.0) {
            rating += 1
        }
        //maybe change this?
        else if (swellHeight <= (targetHeight-targetAllowance) && swellHeight > 2.0){
            rating += 1
        }
        else {
            rating -= 2
        }
        
        //rate wavePeriod
        //15.0
        if(wavePeriod > targetPeriod) {
            rating += 3
        }
        else if(wavePeriod > (targetPeriod-targetAllowance)) {
            rating += 2
        }
        else if(wavePeriod > 10) {
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
    
    func mapTime(data: Initial) -> Time {
        //function will use a nested for loop to add in time and days every 23 (24 days) indexes
        
        var dayTime: [DayTime] = [DayTime(day: "penis", time: Array(repeating: "penis", count: 24))]
        //init array
        for _ in 0...6 {
            let day = DayTime(day: "", time: Array(repeating: "", count: 24)) // Each day has 24 empty slots for time
            dayTime.append(day)
        }
        var allTime: Time = Time(dayTime: dayTime)
        
        //var days = 0; //means 24 days
        var hours = 24 // means 24
        for i in 0...6 {
            
            if(i > 0) {
                allTime.dayTime[i].day = data.hours[hours].time
            }
            else {
                allTime.dayTime[i].day = data.hours[i].time
            }
            for j in 0...23 {
                if(i > 0) {
                    
                    allTime.dayTime[i].time[j] = data.hours[hours].time
                    hours += 1
                }
                else {
                    allTime.dayTime[i].time[j] = data.hours[j].time
                }
            }
            
        }
        return allTime
    }
    
    //current date to MM/YY
    func mapDateToString () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        return dateFormatter.string(from: Date())
    }
    
    //tech debt to reduce repeated code!
    func mapWaveDateToString (time: String) -> String {
        let isoFormatter = ISO8601DateFormatter() //used for these type of time codes
        isoFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withTimeZone, .withColonSeparatorInTime]
        
        if let date = isoFormatter.date(from: time) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            return dateFormatter.string(from: date)
        }
        return "can't find a date"
    }
    
    func mapDateToDayLiteral (time: String) -> String {
        
        let isoFormatter = ISO8601DateFormatter() //used for these type of time codes
        isoFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withTimeZone, .withColonSeparatorInTime]
        
        if let date = isoFormatter.date(from: time) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"
            return dateFormatter.string(from: date)
        }
        return "can't find a date"
        
    }
    
    func mapDateToDayLiteral(time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d'"
        let dayString = dateFormatter.string(from: time)
        let suffix: String
        
        switch Calendar.current.component(.day, from: time) {
        case 1, 21, 31:
            suffix = "st"
        case 2, 22:
            suffix = "nd"
        case 3, 23:
            suffix = "rd"
        default:
            suffix = "th"
        }
        
        return dayString + suffix + " 2024" //temporarily added should get this dynamically!
    }
    
    func mapWaveTimeToString (time: String) -> String {
        let isoFormatter = ISO8601DateFormatter() //used for these type of time codes
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withTimeZone, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        if let date = isoFormatter.date(from: time) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Assuming the provided time is in UTC
            
            let timeString = dateFormatter.string(from: date)
            return timeString
        }
        return "can't find a date"
    }
    
    func deleteFile(fileName: String) {
        
        let fileManager = FileManager.default
        
        // Get the URL for the Documents directory
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            do {
                try fileManager.removeItem(at: fileURL)
                print("File deleted successfully.")
            } catch {
                print("Error deleting file:", error)
            }
        }
    }
    
    func createFileIfNotExists(fileName: String) {
        let fileManager = FileManager.default
        
        // Get the URL for the Documents directory
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            if !fileManager.fileExists(atPath: fileURL.path) {
                let fileContents = "This is the content of the file."
                do {
                    try fileContents.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("File created successfully.")
                } catch {
                    print("Error creating file:", error)
                }
            } else {
                print("File already exists.")
            }
        } else {
            print("Documents directory not found.")
        }
    }
    
    // Call the function with the desired file name
    
    func UpdateAPIData(data: Initial, dbName: String) {
        //try this exact thing
        let filename: String = dbName+".json"
        createFileIfNotExists(fileName: filename)
        //find the file path
        var file: URL
        do {
            file = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(filename)
            print("here is the file: \(filename)")
        } catch {
            fatalError("Coudn't read or create \(filename): \(error.localizedDescription)")
        }
        
        // encode the array with new entry and write to JSON file
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let fileHandle = try FileHandle(forWritingTo: file)
            print("Writing...  📖: \(file.description)")
            try encoder.encode(data).write(to: file )
            
            let fileData = try Data(contentsOf: file)
            // Convert the data to a string (if it's a text file)
            if let fileContent = String(data: fileData, encoding: .utf8) {
                print("File content:")
                print(fileContent)
            } else {
                print("Unable to convert data to string.")
            }
            try fileHandle.close()
        } catch {
            print("Couldn’t save new entry to \(filename), \(error.localizedDescription)")
        }
        
    }
    
    //create within the same function perhaps a range of swell height?
    func normalizeDirection(_ direction: Double) -> Double {
        var normalized = direction
        while normalized < 0 {
            normalized += 360
        }
        while normalized >= 360 {
            normalized -= 360
        }
        return normalized
    }
    
    
    //base off wind wave direction and multiply that by the wind speed??
    func BeachDirection(dir: Double, target: Double) -> String {
        //DIY wave form function based off educated guessed metrics
        
        //example of thought
        //dir = 181 target = 236
        //glassy = 233-239
        //offshore = 218-254
        //cross-off = 178-294
        //normalise vars
        let crossShoreOffset = 38.0
        let offshoreOffset = 18.0
        let glassyOffset = 3.0
        let minOffshoreRange = normalizeDirection(target-offshoreOffset)
        let maxOffshoreRange = normalizeDirection(target+offshoreOffset)
        let minGlassyRange = normalizeDirection(target-glassyOffset)
        let maxGlassyRange = normalizeDirection(target+glassyOffset)
        let minCrossOffshoreRange = normalizeDirection(minOffshoreRange-crossShoreOffset)
        let maxCrossOffshoreRange = normalizeDirection(maxOffshoreRange+crossShoreOffset)
        let minOnshoreRange = normalizeDirection(minOffshoreRange-180)
        let maxOnshoreRange = normalizeDirection(maxOffshoreRange-180)
        
        
        //begin the ifs
        //offshore 220
        if(dir > minGlassyRange && dir < maxGlassyRange) {
            return "Glass"
        }
        //glassy
        else if(dir > minOffshoreRange && dir < maxOffshoreRange) {
            return "Offshore"
        }
        else if(dir > minCrossOffshoreRange && dir < maxCrossOffshoreRange ) {
            return "Cross-Off"
        }
        else if(dir > minOnshoreRange && dir < maxOnshoreRange ) {
            return "Onshore"
        }
        else {
            return "Cross"
        }
    }
    
    func UpdateColourBasedOnForm(form: String) -> String {
        //create assets which I want to switch to depending on wave form
        //could create an array of colors and wave forms and compare string to make the code shorter, however, today I am just going to do if statements lol
        let cross: String = "Color-Cross"
        let glass: String = "Color-Glass"
        let offshore: String = "Color-Offshore"
        let crossOffshore: String = "Color-Cross-Offshore"
        let onshore: String = "Color-Onshore"
        
        if(form=="Glass") {
            return glass
        }
        else if(form=="Offshore") {
            return offshore
        }
        else if(form=="Cross-Off") {
            return crossOffshore
        }
        else if(form=="Onshore") {
            return onshore
        }
        else if(form=="Cross") {
            return cross
        }
        else {
            return "Color-Default"
        }
    }
    
    //incorp wind wave direction?
    func WindProviderAverage(stat: WaveAPIProviders) -> Double {
        //try without noaa
        let noaa = stat.noaa ?? 0.0
        let dwd = stat.dwd ?? 0.0
        let sg = stat.sg ?? 0.0
        let icon = stat.icon ?? 0.0
        let providerArr: [Double] = [noaa, sg, icon, dwd]
        
        var divider: Int = 0;
        for provider in providerArr {
            if(provider != 0.0) {
                divider+=1
            }
        }
        
        var avg = ((noaa + sg + icon + dwd)/Double(divider))
        avg =  self.roundDouble(d: avg)
        
        if(avg.isNaN) {
            avg = 0.0;
        }
        
        return avg
    }
    
    func SwellHeightProviderAverage(stat: WaveAPIProviders, inM: Bool) -> Double {
        //convert sg to meters as it comes in foot
        
        //take out noa for now
        let dwd = stat.dwd ?? 0.0
        //let noaa = stat.noaa ?? 0.0
        //let sg = self.ftToM(ft: stat.sg ?? 0.0)
        let sg = stat.sg ?? 0.0
        let icon = stat.icon ?? 0.0
        let providerArr: [Double] = [sg, icon, dwd]
        
        var divider: Int = 0;
        for provider in providerArr {
            if(provider != 0.0) {
                divider+=1
            }
        }
        
        var avg = ((sg + icon + dwd)/Double(divider))
        avg =  self.roundDouble(d: avg)
        
        if(avg.isNaN) {
            avg = 0.0;
        }
        
        if(inM) {
            return avg
        }
        return self.mToFt(meter: avg)
    }
    
    func TimeSelector(hours: Int, days: Int) -> Int {
        
        //need to do fail safe
        var index = ((days*24)-1)+hours
        
        if(index < 0 || index > self.maxDataCap) {
            index = 0
        }
        
        return index
    }
    
    func fetch(allowApi: Bool, beachTarget: Double, dbName: String, lat: String, lng: String, completion: @escaping (Initial?) -> Void) {
        //create a dummy data to call from now that I know endpoint works under if I want to call the api
        if(allowApi) {
            let params = "swellHeight,wavePeriod,windDirection,windSpeed"
            let myUrl = "https://api.stormglass.io/v2/weather/point?lat="+lat+"&lng="+lng+"&params="+params
            
            // Create a URL pointing to your endpoint
            let apiUrl = URL(string: myUrl)!
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("d95f5210-a038-11ee-af37-0242ac130002-d95f527e-a038-11ee-af37-0242ac130002", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                // Handle the response data
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                }
                
                if let data = data {
                    do {
                        let wave = try JSONDecoder().decode(Initial.self, from: data)
                        DispatchQueue.main.async {
                            completion(wave) // Pass the decoded data to the completion handler
                            self.UpdateAPIData(data: wave, dbName: dbName)
                            print("Updating the db using StromGlass and updating api: \(dbName)")
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(nil)
                    }
                }
            }
            task.resume()
        } else {
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                // Append the file name to the document directory URL
                let fileLocation = documentDirectory.appendingPathComponent(dbName+".json")
                do {
                    let data = try Data(contentsOf: fileLocation)
                    let decoder = JSONDecoder()
                    let forecast = try decoder.decode(Initial.self, from: data)
                    print("Should Grab Data from the db : \(dbName)")
                    completion(forecast)
                } catch {
                    print(error)
                    completion(nil)
                }
            }
        }
    }
}

    


    
      
