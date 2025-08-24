import Foundation
@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics
import Dispatch

func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = Globals.eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
        return Unmanaged.passUnretained(event)
    }
    if type == .leftMouseDown {
        if Globals.globalConfig.enableCloseMinimizer {
            if handleLeftMouseDown(event) == nil { return nil }
        }
        if Globals.globalConfig.enableGreenZoom {
            if greenZoomLeftMouseDown(event) == nil { return nil }
        }
        return Unmanaged.passUnretained(event)
    }
    if type == .leftMouseUp {
        if Globals.swallowNextUp { Globals.swallowNextUp = false; return nil }
        if Globals.swallowMouseUp { Globals.swallowMouseUp = false; return nil }
        return Unmanaged.passUnretained(event)
    }
    if type == .rightMouseDown {
        if Globals.globalConfig.enableClockCleaner {
            if clockRightMouseDown(event) == nil { return nil }
        }
        return Unmanaged.passUnretained(event)
    }
    if type == .rightMouseUp {
        if Globals.swallowNextMouseUp { Globals.swallowNextMouseUp = false; return nil }
        return Unmanaged.passUnretained(event)
    }
    return Unmanaged.passUnretained(event)
}
