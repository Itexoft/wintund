import Foundation
import AppKit
import ApplicationServices
import CoreGraphics

func attributeString(_ el: AXUIElement, _ key: CFString) -> String? {
    var v: CFTypeRef?
    if AXUIElementCopyAttributeValue(el, key, &v) == .success { return v as? String }
    return nil
}

func attributeElement(_ el: AXUIElement, _ key: CFString) -> AXUIElement? {
    var v: CFTypeRef?
    if AXUIElementCopyAttributeValue(el, key, &v) == .success, let value = v, CFGetTypeID(value) == AXUIElementGetTypeID() {
        return unsafeBitCast(value, to: AXUIElement.self)
    }
    return nil
}

func stringAttr(_ e: AXUIElement, _ attr: CFString) -> String? {
    var v: CFTypeRef?
    let r = AXUIElementCopyAttributeValue(e, attr, &v)
    if r == .success, let s = v as? String { return s }
    return nil
}

func parent(_ e: AXUIElement) -> AXUIElement? {
    var v: CFTypeRef?
    let r = AXUIElementCopyAttributeValue(e, kAXParentAttribute as CFString, &v)
    if r == .success, let value = v, CFGetTypeID(value) == AXUIElementGetTypeID() {
        return unsafeBitCast(value, to: AXUIElement.self)
    }
    return nil
}

func enclosingWindow(of e: AXUIElement) -> AXUIElement? {
    var cur: AXUIElement? = e
    var guardCount = 0
    while let c = cur, guardCount < 32 {
        if stringAttr(c, kAXRoleAttribute as CFString) == "AXWindow" { return c }
        cur = parent(c)
        guardCount += 1
    }
    return nil
}

func windowCenter(_ w: AXUIElement) -> CGPoint? {
    var posVal: CFTypeRef?
    var sizeVal: CFTypeRef?
    if AXUIElementCopyAttributeValue(w, kAXPositionAttribute as CFString, &posVal) != .success { return nil }
    if AXUIElementCopyAttributeValue(w, kAXSizeAttribute as CFString, &sizeVal) != .success { return nil }
    var pos = CGPoint.zero
    var size = CGSize.zero
    let pv = posVal as! AXValue
    let sv = sizeVal as! AXValue
    if AXValueGetType(pv) == .cgPoint, AXValueGetValue(pv, .cgPoint, &pos),
       AXValueGetType(sv) == .cgSize, AXValueGetValue(sv, .cgSize, &size) {
        return CGPoint(x: pos.x + size.width / 2.0, y: pos.y + size.height / 2.0)
    }
    return nil
}

func visibleFrameForPoint(_ p: CGPoint) -> NSRect? {
    let screens = NSScreen.screens
    var found: NSScreen?
    for s in screens { if s.frame.contains(p) { found = s; break } }
    if found == nil { found = NSScreen.main }
    guard let screen = found else { return nil }
    return screen.visibleFrame
}

func convertNSRectToAX(_ r: NSRect) -> (CGPoint, CGSize) {
    let maxY = NSScreen.screens.map { $0.frame.maxY }.max() ?? 0
    let axY = maxY - (r.origin.y + r.size.height)
    return (CGPoint(x: r.origin.x, y: axY), CGSize(width: r.size.width, height: r.size.height))
}

func setWindow(_ w: AXUIElement, to rect: NSRect) -> Bool {
    let (p, s) = convertNSRectToAX(rect)
    var pos = p
    var size = s
    guard let pv = AXValueCreate(.cgPoint, &pos), let sv = AXValueCreate(.cgSize, &size) else { return false }
    let r1 = AXUIElementSetAttributeValue(w, kAXPositionAttribute as CFString, pv)
    let r2 = AXUIElementSetAttributeValue(w, kAXSizeAttribute as CFString, sv)
    return r1 == .success && r2 == .success
}
