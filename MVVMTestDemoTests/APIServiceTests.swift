//
//  APIServiceTests.swift
//  MVVMTestDemoTests
//
//  Created by QDSG on 2019/12/4.
//  Copyright © 2019 unitTao. All rights reserved.
//

import XCTest
@testable import MVVMTestDemo

class APIServiceTests: XCTestCase {
    
    var service: APIService?

    override func setUp() {
        super.setUp()
        service = APIService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    func test_fetch_photos() {
        let service = self.service ?? APIService()
        
        let expect = XCTestExpectation(description: "callback")
        
        service.fetchPhoto { (success, photos, error) in
            expect.fulfill()
            XCTAssertEqual(photos.count, 20)
            photos.forEach { photo in
                XCTAssertNotNil(photo.id)
            }
        }
        
        wait(for: [expect], timeout: 3.0)
    }

}
