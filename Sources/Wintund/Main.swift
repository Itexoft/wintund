import Foundation
@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics

@main
struct Main {
    @MainActor static func main() {
        let debug = CommandLine.arguments.contains("--debug")
        if debug { print("debug start") }
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as CFString
        guard AXIsProcessTrustedWithOptions([key: true] as CFDictionary) else {
            fputs("accessibility permission missing\n", stderr)
            exit(1)
        }
        if debug { print("debug accessibility") }
        if !CGPreflightListenEventAccess() && !CGRequestListenEventAccess() {
            fputs("input monitoring permission missing\n", stderr)
            exit(1)
        }
        if debug { print("debug input monitoring") }
        let mask: CGEventMask =
            (CGEventMask(1) << CGEventType.leftMouseDown.rawValue) |
            (CGEventMask(1) << CGEventType.leftMouseUp.rawValue)
        Globals.eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: mask, callback: eventCallback, userInfo: nil)
        guard let tap = Globals.eventTap else { fputs("failed to create event tap\n", stderr); exit(1) }
        if debug { print("debug event tap") }
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        if debug {
            if let e = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: .zero, mouseButton: .left) {
                let r = handleEvent(type: .leftMouseDown, event: e)
                if r == nil { print("debug handler nil") } else { print("debug handler ok") }
            } else {
                print("debug event fail")
            }
        }
        CFRunLoopRun()
    }
}