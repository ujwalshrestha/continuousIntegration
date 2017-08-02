//
//  TaskCellTests.swift
//  MovingHelper
//
//  Created by Braindigit on 8/2/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import MovingHelper

class TaskCellTests: XCTestCase {
    
    func testCheckingCheckboxMarksTaskDone() {
        var testCell: TaskTableViewCell?
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let navVC = mainStoryboard.instantiateInitialViewController() as? UINavigationController,
            listVC = navVC.topViewController as? MasterViewController {
            let tasks = TaskLoader.loadStockTasks()
            listVC.createdMovingTasks(tasks)
            testCell = listVC.tableView(listVC.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as? TaskTableViewCell
            if let cell = testCell {
                //1: Create an expectation to wait for
                let expectation = expectationWithDescription("Task updated")
                
                //2: Create an inline struct which conforms to the test delegate
                //   which allows you to check and see whether it was called or not.
                struct TestDelegate: TaskUpdatedDelegate {
                    let testExpectation: XCTestExpectation
                    let expectedDone: Bool
                    
                    init(updatedExpectation: XCTestExpectation,
                         expectedDoneStateAfterToggle: Bool) {
                        testExpectation = updatedExpectation
                        expectedDone = expectedDoneStateAfterToggle
                    }
                    
                    func taskUpdated(task: Task) {
                        XCTAssertEqual(expectedDone, task.done, "Task done state did not match expected!")
                        testExpectation.fulfill()
                    }
                }
                
                //3: Set up the test task and the cell.
                let testTask = Task(aTitle: "TestTask", aDueDate: .OneMonthAfter)
                XCTAssertFalse(testTask.done, "Newly created task is already done!")
                cell.delegate = TestDelegate(updatedExpectation: expectation,
                                             expectedDoneStateAfterToggle: true)
                cell.configureForTask(testTask)
                
                //4: Make sure the checkbox has the proper starting value
                XCTAssertFalse(cell.checkbox.isChecked, "Checkbox checked for not-done task!")
                
                //5: Send a "tap" event
                cell.checkbox.sendActionsForControlEvents(.TouchUpInside)
                
                //6: Make sure everything got updated.
                XCTAssertTrue(cell.checkbox.isChecked, "Checkbox not checked after tap!")
                waitForExpectationsWithTimeout(1, handler: nil)
            } else {
                XCTFail("Test cell was nil!")
            }
        } else {
            XCTFail("Could not get reference to list VC!")
        }
    }
}