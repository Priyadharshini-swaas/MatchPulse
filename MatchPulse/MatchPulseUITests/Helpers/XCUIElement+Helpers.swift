//
//  XCUIElement+Helpers.swift
//  MatchPulseUITests
//
//  Convenience extensions used across all test files.
//

import XCTest

extension XCUIElement {

    // MARK: - Safe Tap

    /// Waits for the element to exist and then taps it. Fails the test if it
    /// never appears.
    @discardableResult
    func tapWhenReady(timeout: TimeInterval = 10) -> Bool {
        guard waitForExistence(timeout: timeout) else { return false }
        tap()
        return true
    }

    // MARK: - Text Presence

    /// Returns true if any descendant static-text element contains the given string.
    func containsText(_ text: String) -> Bool {
        staticTexts[text].exists
    }

    // MARK: - Existence with Timeout

    var isVisibleOnScreen: Bool {
        exists && isHittable
    }
}

// MARK: - XCUIApplication helpers

extension XCUIApplication {

    /// The current tab-bar tab that is selected (accessible via its label).
    func selectTab(_ label: String) {
        tabBars.buttons[label].tap()
    }

    /// Scrolls until an element becomes hittable (at most `maxSwipes` swipes).
    func scrollTo(_ element: XCUIElement, maxSwipes: Int = 5) {
        var swipes = 0
        while !element.isHittable && swipes < maxSwipes {
            swipeUp()
            swipes += 1
        }
    }
}
