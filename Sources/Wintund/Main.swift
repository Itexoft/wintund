import Foundation
@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics

@main
struct Main {
    @MainActor static func main() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as CFString
        guard AXIsProcessTrustedWithOptions([key: true] as CFDictionary) else {
            fputs("accessibility permission missing\n", stderr)
            exit(1)
        }
        if !CGPreflightListenEventAccess() && !CGRequestListenEventAccess() {
            fputs("input monitoring permission missing\n", stderr)
            exit(1)
        }
        let mask: CGEventMask =
            (CGEventMask(1) << CGEventType.leftMouseDown.rawValue) |
            (CGEventMask(1) << CGEventType.leftMouseUp.rawValue)
        Globals.eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: mask, callback: eventCallback, userInfo: nil)
        guard let tap = Globals.eventTap else { fputs("failed to create event tap\n", stderr); exit(1) }
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        CFRunLoopRun()
    }
}