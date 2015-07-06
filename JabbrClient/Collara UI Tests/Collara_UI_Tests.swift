//
//  Collara_UI_Tests.swift
//  Collara UI Tests
//
//  Created by Sean on 06/07/15.
//  Copyright © 2015 Collara. All rights reserved.
//

import Foundation
import XCTest

class Collara_UI_Tests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUserRegistration_TeamCreation_TopicCreation() {
        let testRound = NSString(format:"%d", Int(NSDate().timeIntervalSince1970));
        
        let app = XCUIApplication()
        app.collectionViews.buttons["Sign Up"].tap()
        
        let textField = app.textFields["Username"]
        textField.tap()
        textField.typeText("testuser" + (testRound as String))
        
        let textField2 = app.textFields["Name"]
        textField2.tap()
        textField2.typeText("T" + (testRound as String))
        
        let textField3 = app.textFields["Email"]
        textField3.tap()
        textField3.typeText("wonderxboy+t" + (testRound as String) + "@gmail.com")
        
        let textField4 = app.textFields["Password"]
        textField4.tap()
        textField4.typeText("Password1")
        
        let textField5 = app.textFields["Repeat Password"]
        textField5.tap()
        textField5.typeText("Password1")
        
        let button = app.buttons["Sign Up"]
        button.tap()
        
        NSThread.sleepForTimeInterval(5)
        
        let element = app.descendantsMatchingType(.Unknown)
        let textField6 = element.textFields["Team Name"]
        textField6.tap()
        textField6.typeText("awesome" + (testRound as String))
        element.buttons["Create Team"].tap()
        
        let button2 = app.descendantsMatchingType(.Unknown).tables.descendantsMatchingType(.Unknown).childrenMatchingType(.Button).elementAtIndex(0)
        button2.tap()
        
        let textField7 = element.textFields["Topic"]
        textField7.tap()
        textField7.typeText("hello")
        
        let goButton = element.buttons["Go"]
        goButton.tap()
        NSThread.sleepForTimeInterval(3)
        
        button2.tap()
        textField7.tap()
        textField7.typeText("welcome")
        goButton.tap()
        NSThread.sleepForTimeInterval(3)
        
        button2.tap()
        textField7.tap()
        textField7.typeText("Ptich-Demo")
        goButton.tap()
        NSThread.sleepForTimeInterval(3)
        
        app.navigationBars["CLAHomeMasterView"].buttons["Menu"].tap()
        app.childrenMatchingType(.Window).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(1).tables.staticTexts["#Ptich-Demo"].tap()
        
        NSThread.sleepForTimeInterval(10)
        
        app.navigationBars["CLAHomeMasterView"].buttons["Menu"].tap()
        
        let menuItem = app.childrenMatchingType(.Window).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(1)
        menuItem.tables.staticTexts["#Ptich-Demo"].tap()
        app.navigationBars["#Ptich-Demo"].buttons["Chat"].tap()
        app.buttons["Home"].tap()
        NSThread.sleepForTimeInterval(3)
        
        app.buttons["Settings"].tap()
        app.buttons["Sign out"].tap()
    }
    
    func testUserSignInAndClickAround() {
        let app = XCUIApplication()
        let collectionView = app.collectionViews
        let usernameTextField = collectionView.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("mike")
        
        let xcuiSecureTextField = collectionView.textFields["_XCUI:Secure"]
        xcuiSecureTextField.tap()
        xcuiSecureTextField.typeText("Password1")
        collectionView.buttons["Sign In"].tap()
        
        NSThread.sleepForTimeInterval(5)
        
        let menuButton = app.navigationBars["CLAHomeMasterView"].buttons["Menu"]
        menuButton.tap()
        app.childrenMatchingType(.Window).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(1).tables.staticTexts["#Customer-Feedback"].tap()
        app.navigationBars["#Customer-Feedback"].buttons["Chat"].tap()
        app.tables.staticTexts["#FeaturePlanning"].tap()
        
        NSThread.sleepForTimeInterval(5)
        
        let featureplanningNavigationBar = app.navigationBars["#FeaturePlanning"]
        featureplanningNavigationBar.buttons["Docs"].tap()
        app.navigationBars["Topic Settings"].buttons["Back"].tap()
        featureplanningNavigationBar.buttons["Chat"].tap()
        
        NSThread.sleepForTimeInterval(5)
        
        let button = app.tables.descendantsMatchingType(.Unknown).childrenMatchingType(.Button).elementAtIndex(0)
        button.tap()
        
        let button2 = app.navigationBars["Create Topic"].childrenMatchingType(.Button).elementAtIndex(0)
        button2.tap()
        
        NSThread.sleepForTimeInterval(5)
        
        app.buttons["Settings"].tap()
        app.buttons["Sign out"].tap()
        
    }
    
}
