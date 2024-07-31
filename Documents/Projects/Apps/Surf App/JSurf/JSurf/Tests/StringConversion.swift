//
//  StringConversion.swift
//  SurfTests
//
//  Created by Jay Steele on 06/01/2024.
//

import XCTest
@testable import JSurf

class StringConversion: XCTestCase {
    let wave = WaveModel()

    func testmapWaveTimeToString() {
        let test = wave.mapWaveTimeToString(time: "2023-12-31T00:00:00+00:00")
        XCTAssertEqual(test, "00:00")
    }

}
