//
//  MathConversion.swift
//  SurfTests
//
//  Created by Jay Steele on 05/01/2024.
//

import XCTest
@testable import JSurf

class MathConversion: XCTestCase {
    let wave = WaveModel() 
    func testRoundDouble() {
        
        let result = wave.roundDouble(d: 102.36473)
        //should resolve
        XCTAssertEqual(result, 102.4)
        //should fail...
        XCTAssertNotEqual(result, 17.9)
    }
    
    func testftTomConversion() {
        //m -> f
        let result1 = wave.mToFt(meter: 4.3)
        //correct
        XCTAssertEqual(result1, 14.1)
        
        //ft -> m
        let result2 = wave.ftToM(ft: 14.1)
        //correct
        XCTAssertEqual(result2, 4.3)
    }
    
    func testDegreeToCardinal() {
        let n = wave.degreeToCardinal(degree: 350)
        let nne = wave.degreeToCardinal(degree: 26)
        let ne = wave.degreeToCardinal(degree: 41)
        let ene = wave.degreeToCardinal(degree: 70)
        let e = wave.degreeToCardinal(degree: 95)
        let ese = wave.degreeToCardinal(degree: 119)
        let se = wave.degreeToCardinal(degree: 140)
        let sse = wave.degreeToCardinal(degree: 151)
        let s = wave.degreeToCardinal(degree: 181)
        let ssw = wave.degreeToCardinal(degree: 210)
        let sw = wave.degreeToCardinal(degree: 225)
        let wsw = wave.degreeToCardinal(degree: 240)
        let w = wave.degreeToCardinal(degree: 265)
        let wnw = wave.degreeToCardinal(degree: 302)
        let nw = wave.degreeToCardinal(degree: 315)
        let nnw = wave.degreeToCardinal(degree: 342)
        
        XCTAssertEqual(n, "N")
        XCTAssertEqual(nne, "NNE")
        XCTAssertEqual(ne, "NE")
        XCTAssertEqual(ene, "ENE")
        XCTAssertEqual(e, "E")
        XCTAssertEqual(ese, "ESE")
        XCTAssertEqual(se, "SE")
        XCTAssertEqual(sse, "SSE")
        XCTAssertEqual(s, "S")
        XCTAssertEqual(ssw, "SSW")
        XCTAssertEqual(sw, "SW")
        XCTAssertEqual(wsw, "WSW")
        XCTAssertEqual(w, "W")
        XCTAssertEqual(wnw, "WNW")
        XCTAssertEqual(nw, "NW")
        XCTAssertEqual(nnw, "NNW")
    }
    
    func testNormaliseDirection() {
        let d1 = wave.normalizeDirection(600)
        XCTAssertEqual(d1, 240)
        
        //manage negatives why doesn't this work
        //        let d2 = wave.normalizeDirection(-100.34)
        //        XCTAssertEqual(d2, 260.34)
    }
    
    func testWindDirectionProviderAverage() {
        let t1 = wave.WindProviderAverage(stat: WaveAPIProviders(noaa: 0.69, sg: 0.69, icon: 0.69, dwd: 0.0))
        let t2 = wave.WindProviderAverage(stat: WaveAPIProviders(noaa: 4.0, sg: 2.0, icon: nil, dwd: 0.0))
        let t3 = wave.WindProviderAverage(stat: WaveAPIProviders(noaa: nil, sg: nil, icon: nil, dwd: 0.0))
        //let t4 = wave.WindDirectionProviderAverage(stat: WaveAPIProviders(noaa: 130.55, sg: 134.3, icon: 130.55, dwd: 0.0))
        
        XCTAssertEqual(t1, 0.7)
        XCTAssertEqual(t2, 3.0)
        XCTAssertEqual(t3, 0.0)
        //XCTAssertEqual(t4, 0.0)// 131.8
        
        
    }
    
    
    func testSwellHeightProviderAverage () {
        //change these stats to reflect sg as meters
        //let sg = wave.ftToM(ft: 2.0)
        //noaa is always nil now!! should probs change this in the future
        let t1 = wave.SwellHeightProviderAverage(stat: WaveAPIProviders(noaa: nil, sg: 2.0, icon: 0.61, dwd: 0.0), inM: false)
        let t2 = wave.SwellHeightProviderAverage(stat: WaveAPIProviders(noaa: nil, sg:nil, icon: 3.0, dwd: 4.0), inM: false)
        let t3 = wave.SwellHeightProviderAverage(stat: WaveAPIProviders(noaa: nil, sg: nil, icon: nil, dwd: 0.0), inM: false)
        let t4 = wave.SwellHeightProviderAverage(stat: WaveAPIProviders(noaa: nil, sg: nil, icon: 2.4, dwd: 0.0), inM: true)
        
        XCTAssertEqual(t1, 4.3)
        XCTAssertEqual(t2, 11.5)
        XCTAssertEqual(t3, 0.0)
        XCTAssertEqual(t4, 2.4)
        
        
    }
//    
    func testGnarlyRating () {
        let t1 = wave.gnarlyRating(swellHeight: 3.0, wavePeriod: 14.5, waveForm: "Cross", windSpeed: 3.0)
        
        XCTAssertEqual(t1, 0)
    }
}
