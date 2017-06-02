//
//  CSVWriter+Test.swift
//  swift-csv
//
//  Created by Matthias Hochgatterer on 02/06/2017.
//  Copyright © 2017 Matthias Hochgatterer. All rights reserved.
//

import XCTest

class CSVWriter_Test: XCTestCase {

    var stream: OutputStream!
    var writer: CSV.Writer!
    
    override func setUp() {
        super.setUp()
        
        stream = OutputStream(toMemory: ())
        let configuration = CSV.Configuration(delimiter: ",")
        writer = CSV.Writer(outputStream: stream, configuration: configuration)
    }
    
    func testQuotedFields() throws {
        try writer.writeLine(of: ["aaa", "b \r\nbb", "ccc"])
        try writer.writeLine(of: ["zzz", "yyy", "xxx"])
        guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            XCTFail("Could not retrieve data")
            return
        }
        
        if let string = String(data: data, encoding: .utf8) {
            let expected = "aaa,\"b \r\nbb\",ccc\nzzz,yyy,xxx"
            XCTAssertEqual(string, expected)
        } else {
            XCTFail("Invalid data \(data)")
        }
    }
    
    func testEmptyFields() throws {
        try writer.writeLine(of: ["zzz", "", "xxx", ""])
        guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            XCTFail("Could not retrieve data")
            return
        }
        
        if let string = String(data: data, encoding: .utf8) {
            let expected = "zzz,,xxx,"
            XCTAssertEqual(string, expected)
        } else {
            XCTFail("Invalid data \(data)")
        }
    }
    
    func testSemicolonDelimiter() throws {
        let writer = CSV.Writer(outputStream: stream, configuration: CSV.Configuration(delimiter: ";"))
        try writer.writeLine(of: ["zzz", "yyy", "xxx"])
        guard let data = stream.property(forKey: .dataWrittenToMemoryStreamKey) as? Data else {
            XCTFail("Could not retrieve data")
            return
        }
        
        if let string = String(data: data, encoding: .utf8) {
            let expected = "zzz;yyy;xxx"
            XCTAssertEqual(string, expected)
        } else {
            XCTFail("Invalid data \(data)")
        }
    }
}
