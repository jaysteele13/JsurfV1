//
//  MappingData.swift
//  JSurf
//
//  Created by Jay Steele on 20/04/2024.
//

import Foundation

public class MappingData {
    
    // make own wave stats -> that only needs waves and beachWindDirTarget? for form
    func mapWaveDateToString (time: String) -> String {
        let isoFormatter = ISO8601DateFormatter() //used for these type of time codes
        isoFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate, .withTime, .withTimeZone, .withColonSeparatorInTime]
        
        if let date = isoFormatter.date(from: time) {
            let day = DateFormatter()
            let time = DateFormatter()
            day.dateFormat = "dd/MM"
            time.dateFormat = "HH:mm"
            time.timeZone = TimeZone(secondsFromGMT: 0) // Assuming the provided time is in UTC
            
            let dayString = day.string(from: date)
            let timeString = time.string(from: date)
            
            return "\(timeString) \(dayString)"
        }
        return "can't find a date"
    }
    
    
    func mapWaveStats(waves: Initial, beachTarget: Double, index: Int = 0, stats: [WaveStats] = Array(repeating: WaveStats(swellSize: 0.0, windDirection: "Default", swellPeriod: 0.0, windSpeed: 0.0, waveEnergy: 0.0, waveForm: "Default", formColor: "Color-Default"), count: 168)) -> [WaveStats] {
        
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

        updatedStats[index].swellPeriod = WaveModel().roundDouble(d: waves.hours[index].wavePeriod.noaa ?? 0.069)
        
        updatedStats[index].waveEnergy = WaveModel().waveEnergy(swellHeight: WaveModel().SwellHeightProviderAverage(stat: waves.hours[index].swellHeight, inM: true), swellPeriod: updatedStats[index].swellPeriod)
        
        updatedStats[index].swellSize =  WaveModel().SwellHeightProviderAverage(stat: waves.hours[index].swellHeight, inM: false)
        
        updatedStats[index].windSpeed = WaveModel().mToMph(m: WaveModel().WindProviderAverage(stat: waves.hours[index].windSpeed))
        
        let windDirectionDegree = WaveModel().WindProviderAverage(stat: waves.hours[index].windDirection)
        
        updatedStats[index].windDirection = WaveModel().degreeToCardinal(degree: windDirectionDegree)
        
        //beach target should be good?
        updatedStats[index].waveForm = WaveModel().BeachDirection(dir: windDirectionDegree, target: beachTarget)
        
        updatedStats[index].formColor = WaveModel().UpdateColourBasedOnForm(form: updatedStats[index].waveForm)
        
        // update mapped time to return 00:00 dd/mm
        
        updatedStats[index].time = mapWaveDateToString(time: waves.hours[index].time)
        
        
        // Recursive call to process the next index
        return mapWaveStats(waves: waves, beachTarget: beachTarget, index: index + 1, stats: updatedStats)
    }
    
    
    
    
    
}
