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
        
        let app = XCUIApplication()
        app.collectionViews.buttons["注册"].tap()
        
        let textField = app.textFields["用户名"]
        textField.tap()
        textField.typeText("testuser10")
        
        let textField2 = app.textFields["姓名"]
        textField2.tap()
        textField2.typeText("T10")
        
        let textField3 = app.textFields["邮箱"]
        textField3.tap()
        textField3.typeText("wonderxboy+t10@gmail.com")
        
        let textField4 = app.textFields["密码"]
        textField4.tap()
        textField4.typeText("Password1")
        
        let textField5 = app.textFields["重复密码"]
        textField5.tap()
        textField5.typeText("Password1")
        
        let button = app.buttons["注册"]
        button.tap()
        
        let element = app.descendantsMatchingType(.Unknown)
        let textField6 = element.textFields["团队名称"]
        textField6.tap()
        textField6.typeText("awesome10")
        element.buttons["创建团队"].tap()
        
        let button2 = app.descendantsMatchingType(.Unknown).tables.descendantsMatchingType(.Unknown).childrenMatchingType(.Button).elementAtIndex(0)
        button2.tap()
        
        let textField7 = element.textFields["话题"]
        textField7.tap()
        textField7.typeText("hello")
        
        let goButton = element.buttons["Go"]
        goButton.tap()
        button2.tap()
        textField7.tap()
        textField7.typeText("welcome")
        goButton.tap()
        button2.tap()
        textField7.tap()
        textField7.typeText("Ptich-Demo")
        goButton.tap()
        app.navigationBars["CLAHomeMasterView"].buttons["菜单"].tap()
        app.childrenMatchingType(.Window).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(1).tables.staticTexts["#Ptich-Demo"].tap()
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
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
