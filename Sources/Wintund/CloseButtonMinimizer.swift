import Foundation
import ApplicationServices
import CoreGraphics

func elementAtPoint(_ p: CGPoint) -> AXUIElement? {
    var e: AXUIElement?
    AXUIElementCopyElementAtPosition(Globals.systemWide, Float(p.x), Float(p.y), &e)
    return e
}

func findCloseButtonAncestor(_ el: AXUIElement) -> AXUIElement? {
    var cur: AXUIElement? = el
    var depth = 0
    while let c = cur, depth < 16 {
        if stringAttr(c, kAXRoleAttribute as CFString) == "AXButton", stringAttr(c, kAXSubroleAttribute as CFString) == "AXCloseButton" {
            return c
        }
        cur = parent(c)
        depth += 1
    }
    return nil
}

func ancestorWindow(from el: AXUIElement) -> AXUIElement? {
    var cur: AXUIElement? = el
    var depth = 0
    while let c = cur, depth < 32 {
        if stringAttr(c, kAXRoleAttribute as CFString) == "AXWindow" { return c }
        cur = parent(c)
        depth += 1
    }
    return nil
}

func minimizeWindow(_ w: AXUIElement) -> Bool {
    AXUIElementSetAttributeValue(w, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
    return true
}

@MainActor
func handleLeftMouseDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    let loc = event.location
    if let el = elementAtPoint(loc), let closeEl = findCloseButtonAncestor(el), let win = ancestorWindow(from: closeEl) {
        if minimizeWindow(win) {
            Globals.swallowNextUp = true
            return nil
        }
    }
    return Unmanaged.passUnretained(event)
}
