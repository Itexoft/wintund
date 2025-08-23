import Foundation
import AppKit
import ApplicationServices
import CoreGraphics
import Dispatch

@main
@MainActor
struct Main {
    static func main() {
        systemWide = AXUIElementCreateSystemWide()
        globalConfig = loadConfig(path: {
            var p: String?
            var it = CommandLine.arguments.makeIterator()
            _ = it.next()
            while let a = it.next() {
                if a == "--config", let v = it.next() { p = v; break }
            }
            return p
        }())
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        _ = AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
        let mask: CGEventMask =
            (CGEventMask(1) << CGEventType.leftMouseDown.rawValue) |
            (CGEventMask(1) << CGEventType.leftMouseUp.rawValue) |
            (CGEventMask(1) << CGEventType.rightMouseDown.rawValue) |
            (CGEventMask(1) << CGEventType.rightMouseUp.rawValue)
        eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: mask, callback: eventCallback, userInfo: nil)
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
