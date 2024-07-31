//
//  DailyRequests.swift
//  JSurf
//
//  Created by Jay Steele on 14/03/2024.
//

import Foundation

public class DailyRequests: ObservableObject {
    @Published var lastDay: Date = Date()
    @Published var isToday = false //if is today false then do fetch for all three beaches if not ignore
    
    
    let lastDayKeyName = "lastDay"
    let lastHitKeyName = "lastHit"
    //set this to 0
    
    
    //do this last
    func setLastDay() {
        UserDefaults.standard.set(Date(), forKey: lastDayKeyName)
    }
    
    func getLastDay() -> Date? {
        return UserDefaults.standard.value(forKey: lastDayKeyName) as? Date
    }
    
    func setLastHit(hit: Int = 0) {
        UserDefaults.standard.set(hit, forKey: lastHitKeyName)
    }
    
    func getLastHit() -> Int {
        return UserDefaults.standard.integer(forKey: lastHitKeyName)
    }
    
    //if false we should run the setLastDay function, when its true and we also havnt ran the fetch command then we will run api fetch (will have another cached var for this
    func isNewDay() -> Bool {
        var isToday = false
        if let tempDate = UserDefaults.standard.object(forKey: lastDayKeyName) {
            self.lastDay = tempDate as! Date
            print("----> retrieved lastDay: \(self.lastDay)")
            if Calendar.current.isDate(Date(), inSameDayAs: self.lastDay) {
                isToday = true
            }
            
        }
        return isToday
    }
}

// if it is 8 am or later do something
//                if let thisHour = Calendar.current.dateComponents([.hour], from: Date()).hour {
//                    if (thisHour >= self.selectedTime) {
//                        print("----> it is 8am or later --> do something")
//                        // self.doSomething()
//                    }
//                }
