import Foundation
import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics
import Dispatch

func performFill(on window: AXUIElement) -> Bool {
    guard let center = windowCenter(window), let vis = visibleFrameForPoint(center) else { return false }
    return setWindow(window, to: vis)
}

func synthesizeAltClick(at p: CGPoint) {
    let optDown = CGEvent(keyboardEventSource: nil, virtualKey: 58, keyDown: true)
    optDown?.post(tap: .cghidEventTap)
    let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: p, mouseButton: .left)
    down?.flags = [.maskAlternate]
    down?.post(tap: .cghidEventTap)
    let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: p, mouseButton: .left)
    up?.flags = [.maskAlternate]
    up?.post(tap: .cghidEventTap)
    let optUp = CGEvent(keyboardEventSource: nil, virtualKey: 58, keyDown: false)
    optUp?.post(tap: .cghidEventTap)
}

func greenZoomLeftMouseDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    if event.flags.contains(.maskAlternate) { return Unmanaged.passUnretained(event) }
    let loc = event.location
    var elem: AXUIElement?
    _ = AXUIElementCopyElementAtPosition(Globals.systemWide, Float(loc.x), Float(loc.y), &elem)
    if let e = elem, stringAttr(e, kAXSubroleAttribute as CFString) == "AXFullScreenButton" {
        if let win = enclosingWindow(of: e), performFill(on: win) {
            Globals.swallowMouseUp = true
            return nil
        }
        Globals.swallowMouseUp = true
        synthesizeAltClick(at: loc)
        return nil
    }
    return Unmanaged.passUnretained(event)
}
