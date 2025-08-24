import Foundation
import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics
import Dispatch

func isClockHit(at point: CGPoint) -> Bool {
    var element: AXUIElement?
    let res = AXUIElementCopyElementAtPosition(Globals.systemWide, Float(point.x), Float(point.y), &element)
    guard res == .success, let hit = element else { return false }
    var current: AXUIElement? = hit
    var depth = 0
    while let e = current, depth < 20 {
        if let ident = attributeString(e, kAXIdentifierAttribute as CFString), ident == "com.apple.menuextra.clock" { return true }
        current = attributeElement(e, kAXParentAttribute as CFString)
        depth += 1
    }
    return false
}

func minimizeAllWindows() {
    for app in NSWorkspace.shared.runningApplications {
        if app.activationPolicy != .regular { continue }
        let appAX = AXUIElementCreateApplication(app.processIdentifier)
        var value: CFTypeRef?
        if AXUIElementCopyAttributeValue(appAX, kAXWindowsAttribute as CFString, &value) == .success, let windows = value as? [AXUIElement] {
            for w in windows { AXUIElementSetAttributeValue(w, kAXMinimizedAttribute as CFString, kCFBooleanTrue) }
        }
    }
}

func hideAllVisibleApps() {
    let me = ProcessInfo.processInfo.processIdentifier
    for app in NSWorkspace.shared.runningApplications {
        if app.processIdentifier == me { continue }
        if app.activationPolicy != .regular { continue }
        if !app.isHidden { _ = app.hide() }
    }
}

func cleanDesktop() {
    minimizeAllWindows()
    hideAllVisibleApps()
}

func clockRightMouseDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    let loc = event.location
    if isClockHit(at: loc) {
        Globals.swallowNextMouseUp = true
        DispatchQueue.main.async { cleanDesktop() }
        return nil
    }
    return Unmanaged.passUnretained(event)
}
