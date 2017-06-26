//
//  Reddit_BrowserTests.swift
//  Reddit BrowserTests
//
//  Created by Andy Li on 3/12/17.
//  Copyright © 2017 Andy Li. All rights reserved.
//

import XCTest
@testable import Reddit_Browser

class Reddit_BrowserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSingleton() {
        let singleton = RedditService.shared
        XCTAssertNotNil(singleton)
    }
    
    func testHotPostsDoesNotReturnNil() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.hotPosts()
        
        XCTAssertNotNil(resultsController)
    }
    
    func testTopPostsDoesNotReturnNil() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.topPosts()
        
        XCTAssertNotNil(resultsController)
    }
    
    func testNewPostsDoesNotReturnNil() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.newPosts()
        
        XCTAssertNotNil(resultsController)
    }
    
    func testHotsPostsSingleSection() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.hotPosts()
        
        XCTAssertEqual(resultsController.sections?.count, 1)
    }
    
    func testTopPostsSingleSection() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.topPosts()
        
        XCTAssertEqual(resultsController.sections?.count, 1)
    }
    
    func testNewPostsSingleSection() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.newPosts()
        
        XCTAssertEqual(resultsController.sections?.count, 1)
    }
    
    func testHotPostsRowCount() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.hotPosts()
        
        XCTAssertGreaterThanOrEqual(resultsController.sections?[0].numberOfObjects ?? 0, 1)
    }
    
    func testTopPostsRowCount() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.topPosts()
        
        XCTAssertGreaterThanOrEqual(resultsController.sections?[0].numberOfObjects ?? 0, 1)
    }
    
    func testNewPostsRowCount() {
        let singleton = RedditService.shared
        
        let resultsController = singleton.newPosts()
        
        XCTAssertGreaterThanOrEqual(resultsController.sections?[0].numberOfObjects ?? 0, 1)
    }
    
}
