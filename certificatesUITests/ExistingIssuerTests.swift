//
//  ExistingIssuerTests.swift
//  certificatesUITests
//
//  Created by Chris Downie on 8/18/17.
//  Copyright © 2017 Learning Machine, Inc. All rights reserved.
//

import XCTest

//let testPassphrase = "view virtual ice oven upon material humor vague vessel jacket aim clarify moral gesture canvas wing shoot average charge section issue inmate waste large"

class ExistingDownieIssuerTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        //
        // In these set of tests, we're launching the app
        //   * With a known passphrase, to avoid onboarding
        //   * With an existing issuer (Downie Test Org)
        //
        let issuerData = Bundle(for: type(of: self)).url(forResource: "Downie-Issuer", withExtension: "json")!
        let app = XCUIApplication()
        app.launchArguments = [ "--reset-data", "--use-passphrase", testPassphrase, "--use-issuer-data", issuerData.path]
        app.launch()
    }
    
    func testIssuerDataLoadedCorrectly() {
        let app = XCUIApplication()
        let issuerTile = app.collectionViews.cells["Downie Test Org"]
        
        // The "Issuers" header counts as a cell. Header plus "Downie Test Org" = 2.
        XCTAssertEqual(app.collectionViews.cells.count, 2)
        XCTAssert(issuerTile.exists)
        
        issuerTile.tap()
        let downieTestOrgStaticText = app.tables.staticTexts["Downie Test Org"]
        
        XCTAssert(downieTestOrgStaticText.exists)
    }
    
    func testAddingSecondIssuer() {
        print("\n\n\nTestAddingSecondIssuer\n\n\n")
        defer {
            print("\n\n\nTestAddingSecondIssuer Complete\n\n\n")
        }
        let app = XCUIApplication()
        
        // We start with just one issuer (plus the header = 2)
        XCTAssertEqual(app.collectionViews.cells.count, 2)
        XCTAssertFalse(app.collectionViews.cells["Greendale College"].exists)
        
        // We add a second
        app.navigationBars["Blockcerts Wallet"].buttons["Settings"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Add Issuer"]/*[[".cells[\"Add Issuer\"].staticTexts[\"Add Issuer\"]",".staticTexts[\"Add Issuer\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        let issuerUrlTextView = elementsQuery.textViews["issuer-url-text-view"]
        issuerUrlTextView.tap()
        issuerUrlTextView.typeText("http://localhost:1234/issuer/accepting")
        
        let oneTimeCodeTextView = elementsQuery.textViews["one-time-code-text-view"]
        oneTimeCodeTextView.tap()
        oneTimeCodeTextView.typeText("12345")
        
        elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["Add Issuer"]/*[[".buttons[\"Add Issuer\"].staticTexts[\"Add Issuer\"]",".staticTexts[\"Add Issuer\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssert(app.buttons["Okay"].waitForExistence(timeout: 5))
        app.buttons["Okay"].tap()
        
        let closeButton = app.navigationBars["Settings"].buttons["Close"]
        XCTAssert(closeButton.waitForExistence(timeout: 5))
        closeButton.tap()
        
        // We now have 2 issuers (plust the header = 3), and one of them is Greendale
        XCTAssertEqual(app.collectionViews.cells.count, 3)
        XCTAssert(app.collectionViews.cells["Greendale College"].exists)
    }
    
    func testAddingMismatchedCertificate() {
        let app = XCUIApplication()
        app.collectionViews.cells["Downie Test Org"].tap()
        app.tables.buttons["Add Credential"].tap()
        app.sheets["Add Credential"].scrollViews.otherElements.buttons["Import from URL"].tap()
        
        let credentialUrlTextView = app.textViews["certificate-url-text-view"]
        XCTAssert(credentialUrlTextView.waitForExistence(timeout: 5))
        credentialUrlTextView.tap()
        credentialUrlTextView.typeText("http://localhost:1234/issuer/accepting/certificates/student.json")
        
        app.buttons["Import"].tap()
        XCTAssert(app.buttons["Okay"].waitForExistence(timeout: 5))
        app.buttons["Okay"].tap()
                
        // Back button shouldn't be to DownieTestOrg, but instead should be to Greendale College
        XCTAssert(app.navigationBars["Credential"].waitForExistence(timeout: 5))
        app.navigationBars["Credential"].buttons["Issuer"].tap()
        
        XCTAssert(app.tables.staticTexts["Greendale College"].exists)
        XCTAssert(app.tables.staticTexts["You're a student"].exists)
    }
}

class ExistingAcceptingIssuerTests : XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        //
        // In these set of tests, we're launching the app
        //   * With a known passphrase, to avoid onboarding
        //   * With an existing issuer (Downie Test Org)
        //
        let issuerData = Bundle(for: type(of: self)).url(forResource: "Accepting-Issuer", withExtension: "json")!
        let app = XCUIApplication()
        app.launchArguments = [ "--reset-data", "--use-passphrase", testPassphrase, "--use-issuer-data", issuerData.path]
        app.launch()
    }
    
    func testIssuerDataLoadedCorrectly() {
        let app = XCUIApplication()
        let issuerTile = app.collectionViews.cells["Greendale College"]
        
        // The "Issuers" header counts as a cell. Header plus "Greendale College" = 2.
        XCTAssertEqual(app.collectionViews.cells.count, 2)
        XCTAssert(issuerTile.exists)
        
        issuerTile.tap()
        let greendaleCollegeStaticText = app.tables.staticTexts["Greendale College"]
        
        XCTAssert(greendaleCollegeStaticText.exists)
    }
    
    func testAddingCertificateToIssuer() {
        let app = XCUIApplication()
        app.collectionViews.cells["Greendale College"].tap()
        XCTAssertFalse(app.tables.staticTexts["You're a student"].exists)
        
        app.tables.buttons["Add Credential"].tap()
        app.sheets["Add Credential"].scrollViews.otherElements.buttons["Import from URL"].tap()
        
        let credentialUrlTextView = app.textViews["certificate-url-text-view"]
        XCTAssert(credentialUrlTextView.waitForExistence(timeout: 5))
        credentialUrlTextView.tap()
        credentialUrlTextView.typeText("http://localhost:1234/issuer/accepting/certificates/student.json")
        
        app.buttons["Import"].tap()
        XCTAssert(app.buttons["Okay"].waitForExistence(timeout: 5))
        app.buttons["Okay"].tap()
        
        XCTAssert(app.navigationBars["Credential"].waitForExistence(timeout: 5))
        app.navigationBars["Credential"].buttons["Issuer"].tap()
        
        XCTAssert(app.tables.staticTexts["Greendale College"].exists)
        XCTAssert(app.tables.staticTexts["You're a student"].exists)
    }
}
