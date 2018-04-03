import XCTest

import codableRequestTests

var tests = [XCTestCaseEntry]()
tests += codableRequestTests.allTests()
XCTMain(tests)