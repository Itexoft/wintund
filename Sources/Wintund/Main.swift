import Foundation
import AppKit
@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics
import Dispatch

@main
struct Main {
    @MainActor static func main() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as CFString
        _ = AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
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