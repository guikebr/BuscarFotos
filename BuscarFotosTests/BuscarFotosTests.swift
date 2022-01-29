//
//  BuscarFotosTests.swift
//  BuscarFotosTests
//
//  Created by Admin on 27/01/22.
//

import XCTest
@testable import BuscarFotos

class BuscarFotosTests: XCTestCase {
    var httpClient: HttpClient!
    let session = MockURLSession()
    
    override func setUp() {
        super.setUp()
        httpClient = HttpClient(session: session)
    }
    
    func test_getRequestWithURL() {
        guard let url = URL(string: "https://api.imgur.com/3") else {
            fatalError("URL não pode ser vazia")
        }
        httpClient.get(url: url) { (success, response) in
            // Return data
        }
        XCTAssert(session.lastURL == url)
    }
    
    func test_getResumeCalled() {
        let dataTask = MockURLSessionDataTask()
        session.nextDataTask = dataTask
        
        guard let url = URL(string: "https://api.imgur.com/3") else {
            fatalError("URL não pode ser vazia")
        }
        httpClient.get(url: url) { (success, response) in
            // Return data
        }
        XCTAssert(dataTask.resumeWasCalled)
    }
    
    func test_getShouldReturnData() {
        let expectedData = "{}".data(using: .utf8)
        
        session.nextData = expectedData
        
        var actualData: Data?
        httpClient.get(url: URL(string: "https://api.imgur.com/3")!) { (data, error) in
            actualData = data
        }
        XCTAssertNotNil(actualData)
    }
}
