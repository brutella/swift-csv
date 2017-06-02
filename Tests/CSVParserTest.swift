//
//  CSVParserTest.swift
//  swift-csv
//
//  Created by Matthias Hochgatterer on 02/06/2017.
//  Copyright © 2017 Matthias Hochgatterer. All rights reserved.
//

import XCTest

class TestParserDelegate: ParserDelegate {
    
    internal var didBeginDocument: Bool = false
    internal var didEndDocument: Bool = false
    internal var didBeginLineIndex: UInt?
    
    internal var content = Array<[String]>()
    internal var currentFieldValues = Array<String>()
    
    func parserDidBeginDocument(_ parser: CSV.Parser) {
        didBeginDocument = true
        print(#function)
    }
    
    func parserDidEndDocument(_ parser: CSV.Parser) {
        didEndDocument = true
        print(#function)
    }
    
    func parser(_ parser: CSV.Parser, didBeginLineAt index: UInt) {
        didBeginLineIndex = index
        currentFieldValues.removeAll()
        print("\(#function) \(index)")
    }
    
    func parser(_ parser: CSV.Parser, didEndLineAt index: UInt) {
        guard let beginLineIndex = didBeginLineIndex else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(beginLineIndex, index)
        content.append(currentFieldValues)
        print("\(#function) \(index)")
    }
    
    func parser(_ parser: CSV.Parser, didReadFieldAt index: UInt, value: String) {
        currentFieldValues.append(value)
        print("\(#function) \(value)")
    }
}

class CSVParser_Test: XCTestCase {
    
    func testQuotedFields() throws {
        let string = "\"aaa\",\"b \r\nbb\",\"ccc\" \r\nzzz,yyy,xxx"
        let parser = CSV.Parser(string: string, configuration: CSV.Configuration(delimiter: ","))
        let testDelegate = TestParserDelegate()
        parser.delegate = testDelegate
        try parser.parse()
        
        XCTAssertTrue(testDelegate.didBeginDocument)
        XCTAssertTrue(testDelegate.didEndDocument)
        
        let line0 = ["aaa", "b \r\nbb","ccc"]
        let line1 = ["zzz", "yyy", "xxx"]
        XCTAssertEqual(testDelegate.content[0], line0)
        XCTAssertEqual(testDelegate.content[1], line1)
    }
    
    func testQuoteInQuotedFields() throws {
        let string = "\"z\"\"zz\";;xxx;"
        let parser = CSV.Parser(string: string, configuration: CSV.Configuration(delimiter: ";"))
        let testDelegate = TestParserDelegate()
        parser.delegate = testDelegate
        try parser.parse()
        
        XCTAssertEqual(testDelegate.content[0], ["z\"zz", "", "xxx", ""])
    }
    
    func testEmptyFields() throws {
        let string = "zzz;;xxx;"
        let parser = CSV.Parser(string: string, configuration: CSV.Configuration(delimiter: ";"))
        let testDelegate = TestParserDelegate()
        parser.delegate = testDelegate
        try parser.parse()
        
        XCTAssertEqual(testDelegate.content[0], ["zzz", "", "xxx", ""])
    }
    
    func testSemicolonDelimiter() throws {
        let string = "zzz;yyy;xxx"
        let parser = CSV.Parser(string: string, configuration: CSV.Configuration(delimiter: ";"))
        let testDelegate = TestParserDelegate()
        parser.delegate = testDelegate
        try parser.parse()
        
        XCTAssertEqual(testDelegate.content[0], ["zzz", "yyy", "xxx"])
    }
    
    func testCR() throws {
        let string = "First name,Last name\rJohn,Doe"
        let parser = CSV.Parser(string: string, configuration: CSV.Configuration(delimiter: ","))
        
        let testDelegate = TestParserDelegate()
        parser.delegate = testDelegate
        try parser.parse()
        
        let line0 = ["First name", "Last name"]
        let line1 = ["John","Doe"]
        XCTAssertEqual(testDelegate.content[0], line0)
        XCTAssertEqual(testDelegate.content[1], line1)
    }
    
    func testLF() throws {
        let string = "First name,Last name\nJohn,Doe"
        let parser = CSV.Parser(string: string, configuration: CSV.Configuration(delimiter: ","))
        
        let testDelegate = TestParserDelegate()
        parser.delegate = testDelegate
        try parser.parse()
        
        let line0 = ["First name", "Last name"]
        let line1 = ["John","Doe"]
        XCTAssertEqual(testDelegate.content[0], line0)
        XCTAssertEqual(testDelegate.content[1], line1)
    }
    
    func testCRLF() throws {
        let string = "First name,Last name\r\nJohn,Doe"
        let parser = CSV.Parser(string: string, configuration: CSV.Configuration(delimiter: ","))
        
        let testDelegate = TestParserDelegate()
        parser.delegate = testDelegate
        try parser.parse()
        
        let line0 = ["First name", "Last name"]
        let line1 = ["John","Doe"]
        XCTAssertEqual(testDelegate.content[0], line0)
        XCTAssertEqual(testDelegate.content[1], line1)
    }
    
    func testCSVSpectrumFiles() throws {
        let data: [String: Array<[String]>] = [
            "first,last,address,city,zip\nJohn,Doe,120 any st.,\"Anytown, WW\",08123": [["first", "last", "address", "city", "zip"],["John","Doe","120 any st.","Anytown, WW","08123"]],
            "a,b,c\n1,\"\",\"\"\n2,3,4": [["a","b","c"],["1","",""], ["2","3","4"]],
            "a,b\n1,\"ha \"\"ha\"\" ha\"\n3,4": [["a","b"],["1","ha \"ha\" ha"], ["3","4"]],
            "key,val\n1,\"{\"\"type\"\": \"\"Point\"\", \"\"coordinates\"\": [102.0, 0.5]}\"": [["key","val"],["1","{\"type\": \"Point\", \"coordinates\": [102.0, 0.5]}"]],
            "a,b,c\n1,2,3\n\"Once upon\na time\",5,6\n7,8,9": [["a", "b", "c"], ["1", "2", "3"], ["Once upon\na time", "5", "6"], ["7", "8", "9"]],
            "a,b,c\n1,2,3": [["a","b","c"],["1","2","3"]],
            "a,b,c\r\n1,2,3": [["a","b","c"],["1","2","3"]],
            "a,b,c\r\n1,2,3\n4,5,ʤ": [["a","b","c"],["1","2","3"], ["4","5","ʤ"]],
        ]
        
        for (key, value) in data {
            let parser = CSV.Parser(string: key, configuration: CSV.Configuration(delimiter: ","))
            
            let testDelegate = TestParserDelegate()
            parser.delegate = testDelegate
            try parser.parse()
            
            guard testDelegate.content.count == value.count else {
                XCTFail("Invalid number of lines")
                return
            }
            for (index, line) in value.enumerated() {
                XCTAssertEqual(line, testDelegate.content[index])
            }
        }
    }
}
