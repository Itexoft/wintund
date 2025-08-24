@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics

@MainActor
func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
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
        if Globals.swallowPlainUp && !event.flags.contains(.maskAlternate) { Globals.swallowPlainUp = false; return nil }
        if Globals.swallowNextUp { Globals.swallowNextUp = false; return nil }
        if Globals.swallowMouseUp { Globals.swallowMouseUp = false; return nil }
        return Unmanaged.passUnretained(event)
    }
    return Unmanaged.passUnretained(event)
}

let eventCallback: CGEventTapCallBack = { _, type, event, _ in
    MainActor.assumeIsolated { handleEvent(type: type, event: event) }
}