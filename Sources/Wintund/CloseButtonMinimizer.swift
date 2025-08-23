import Foundation
import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics
import Dispatch

func isCloseButton(_ el: AXUIElement) -> Bool {
    if let subrole = attributeString(el, kAXSubroleAttribute as CFString) { return subrole == "AXCloseButton" }
    return false
}

func isWindow(_ el: AXUIElement) -> Bool {
    if let role = attributeString(el, kAXRoleAttribute as CFString) { return role == "AXWindow" }
    return false
}

func ancestorWindow(from el: AXUIElement) -> AXUIElement? {
    var current: AXUIElement? = el
    var guardCount = 0
    while let c = current, guardCount < 32 {
        if isWindow(c) { return c }
        current = attributeElement(c, kAXParentAttribute as CFString)
        guardCount += 1
    }
    return nil
}

func findCloseButtonAncestor(_ el: AXUIElement) -> AXUIElement? {
    var current: AXUIElement? = el
    var guardCount = 0
    while let c = current, guardCount < 32 {
        if isCloseButton(c) { return c }
        current = attributeElement(c, kAXParentAttribute as CFString)
        guardCount += 1
    }
    return nil
}

func elementAtPoint(_ p: CGPoint) -> AXUIElement? {
    let sys = AXUIElementCreateSystemWide()
    var el: AXUIElement?
    _ = AXUIElementCopyElementAtPosition(sys, Float(p.x), Float(p.y), &el)
    return el
}

func minimizeWindow(_ win: AXUIElement) -> Bool {
    let r = AXUIElementSetAttributeValue(win, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
    if r == .success { return true }
    let src = CGEventSource(stateID: .hidSystemState)
    let down = CGEvent(keyboardEventSource: src, virtualKey: 0x2E, keyDown: true)
    let up = CGEvent(keyboardEventSource: src, virtualKey: 0x2E, keyDown: false)
    down?.flags = .maskCommand
    up?.flags = .maskCommand
    down?.post(tap: .cghidEventTap)
    up?.post(tap: .cghidEventTap)
    return true
}

@MainActor func handleLeftMouseDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    let loc = event.location
    if let el = elementAtPoint(loc), let closeEl = findCloseButtonAncestor(el), let win = ancestorWindow(from: closeEl) {
        if minimizeWindow(win) {
            Globals.swallowNextUp = true
            return nil
        }
    }
    return Unmanaged.passUnretained(event)
}
