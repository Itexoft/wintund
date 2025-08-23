import Foundation
import AppKit
import ApplicationServices
import CoreGraphics
import Dispatch

@main
struct Main {
    static func main() {
        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt as String: true] as CFDictionary)
        let mask: CGEventMask =
            (CGEventMask(1) << CGEventType.leftMouseDown.rawValue) |
            (CGEventMask(1) << CGEventType.leftMouseUp.rawValue) |
            (CGEventMask(1) << CGEventType.rightMouseDown.rawValue) |
            (CGEventMask(1) << CGEventType.rightMouseUp.rawValue)
        eventTap = CGEventTapCreate(.cghidEventTap, .headInsertEventTap, .defaultTap, mask, eventCallback, nil)
        if let tap = eventTap {
            let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            startFixDockIfNeeded()
            CFRunLoopRun()
        } else {
            fputs("failed to create event tap\n", stderr)
            exit(1)
        }
    }
}
