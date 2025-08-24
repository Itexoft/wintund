import AppKit
@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics

@MainActor
func greenZoomLeftMouseDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    if event.flags.contains(.maskAlternate) { return Unmanaged.passUnretained(event) }
    let loc = event.location
    var elem: AXUIElement?
    _ = AXUIElementCopyElementAtPosition(Globals.systemWide, Float(loc.x), Float(loc.y), &elem)
    if let e = elem, attributeString(e, kAXSubroleAttribute as CFString) == "AXFullScreenButton" {
        synthesizeAltClick(at: loc)
        Globals.swallowPlainUp = true
        return nil
    }
    return Unmanaged.passUnretained(event)
}