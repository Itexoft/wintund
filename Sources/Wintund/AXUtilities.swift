import Foundation
@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics

@MainActor
func attributeString(_ el: AXUIElement, _ key: CFString) -> String? {
    var v: CFTypeRef?
    if AXUIElementCopyAttributeValue(el, key, &v) == .success, let value = v {
        if let s = value as? String { return s }
        if CFGetTypeID(value) == CFStringGetTypeID() { return (unsafeDowncast(value, to: CFString.self)) as String }
    }
    return nil
}

@MainActor
func attributeElement(_ el: AXUIElement, _ key: CFString) -> AXUIElement? {
    var v: CFTypeRef?
    if AXUIElementCopyAttributeValue(el, key, &v) == .success, let value = v {
        if CFGetTypeID(value) == AXUIElementGetTypeID() { return unsafeDowncast(value, to: AXUIElement.self) }
    }
    return nil
}

@MainActor
func attributeArray(_ el: AXUIElement, _ key: CFString) -> [AXUIElement]? {
    var v: CFTypeRef?
    if AXUIElementCopyAttributeValue(el, key, &v) != .success || v == nil { return nil }
    let value = v!
    if CFGetTypeID(value) != CFArrayGetTypeID() { return nil }
    let arr = unsafeDowncast(value, to: CFArray.self)
    let count = CFArrayGetCount(arr)
    var result: [AXUIElement] = []
    result.reserveCapacity(count)
    for i in 0..<count {
        guard let raw = CFArrayGetValueAtIndex(arr, i) else { continue }
        let any = Unmanaged<AnyObject>.fromOpaque(raw).takeUnretainedValue()
        if CFGetTypeID(any) == AXUIElementGetTypeID() {
            result.append(unsafeDowncast(any, to: AXUIElement.self))
        }
    }
    return result
}

@MainActor
func isCloseButton(_ el: AXUIElement) -> Bool {
    if let subrole = attributeString(el, kAXSubroleAttribute as CFString) { return subrole == "AXCloseButton" }
    return false
}

@MainActor
func isWindow(_ el: AXUIElement) -> Bool {
    if let role = attributeString(el, kAXRoleAttribute as CFString) { return role == "AXWindow" }
    return false
}

@MainActor
func ancestorWindow(from el: AXUIElement) -> AXUIElement? {
    var current: AXUIElement? = el
    var guardCount = 0
    while let c = current, guardCount < 32 {
        if isWindow(c) { return c }
        current = attributeElement(c, kAXParentAttribute as CFString)
        guardCount += 1
    }
    return nil
}

@MainActor
func findCloseButtonAncestor(_ el: AXUIElement) -> AXUIElement? {
    var current: AXUIElement? = el
    var guardCount = 0
    while let c = current, guardCount < 32 {
        if isCloseButton(c) { return c }
        current = attributeElement(c, kAXParentAttribute as CFString)
        guardCount += 1
    }
    return nil
}

@MainActor
func windowForCloseButton(_ el: AXUIElement) -> AXUIElement? {
    var pid: pid_t = 0
    AXUIElementGetPid(el, &pid)
    let app = AXUIElementCreateApplication(pid)

    if let wins: [AXUIElement] = attributeArray(app, kAXWindowsAttribute as CFString) {
        for w in wins {
            if let b = attributeElement(w, kAXCloseButtonAttribute as CFString) {
                if elementsEqual(el, b) || isAncestor(b, of: el) || isAncestor(el, of: b) { return w }
            }
        }
    }

    if let w = attributeElement(el, kAXWindowAttribute as CFString) { return w }
    if let t = attributeElement(el, kAXTopLevelUIElementAttribute as CFString) { return t }
    return ancestorWindow(from: el)
}

func elementsEqual(_ a: AXUIElement, _ b: AXUIElement) -> Bool {
    CFEqual(a, b)
}

@MainActor
func isAncestor(_ ancestor: AXUIElement, of child: AXUIElement) -> Bool {
    var cur: AXUIElement? = child
    var guardCount = 0
    while let c = cur, guardCount < 64 {
        if CFEqual(c, ancestor) { return true }
        cur = attributeElement(c, kAXParentAttribute as CFString)
        guardCount += 1
    }
    return false
}

@MainActor
func enclosingWindow(of e: AXUIElement) -> AXUIElement? {
    var cur: AXUIElement? = e
    var guardCount = 0
    while let c = cur, guardCount < 32 {
        if attributeString(c, kAXRoleAttribute as CFString) == "AXWindow" { return c }
        cur = attributeElement(c, kAXParentAttribute as CFString)
        guardCount += 1
    }
    return nil
}

@MainActor
func synthesizeAltClick(at p: CGPoint) {
    let optDown = CGEvent(keyboardEventSource: nil, virtualKey: 58, keyDown: true)
    optDown?.post(tap: .cghidEventTap)
    let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: p, mouseButton: .left)
    down?.flags = [.maskAlternate]
    down?.post(tap: .cghidEventTap)
    let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: p, mouseButton: .left)
    up?.flags = [.maskAlternate]
    up?.post(tap: .cghidEventTap)
    let optUp = CGEvent(keyboardEventSource: nil, virtualKey: 58, keyDown: false)
    optUp?.post(tap: .cghidEventTap)
}