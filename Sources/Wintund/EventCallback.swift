import Foundation
import AppKit
import ApplicationServices
import CoreGraphics
import Dispatch

@MainActor
func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
        return Unmanaged.passUnretained(event)
    }
    if type == .leftMouseDown {
        if globalConfig.enableCloseMinimizer {
            if handleLeftMouseDown(event) == nil { return nil }
        }
        if globalConfig.enableGreenZoom {
            if greenZoomLeftMouseDown(event) == nil { return nil }
        }
        return Unmanaged.passUnretained(event)
    }
    if type == .leftMouseUp {
        if swallowNextUp { swallowNextUp = false; return nil }
        if swallowMouseUp { swallowMouseUp = false; return nil }
        return Unmanaged.passUnretained(event)
    }
    if type == .rightMouseDown {
        if globalConfig.enableClockCleaner {
            if clockRightMouseDown(event) == nil { return nil }
        }
        return Unmanaged.passUnretained(event)
    }
    if type == .rightMouseUp {
        if swallowNextMouseUp { swallowNextMouseUp = false; return nil }
        return Unmanaged.passUnretained(event)
    }
    return Unmanaged.passUnretained(event)
}
