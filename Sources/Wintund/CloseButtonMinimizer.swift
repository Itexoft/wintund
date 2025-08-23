@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics
import AppKit

@MainActor
func appOfWindow(_ win: AXUIElement) -> NSRunningApplication? {
    var pid: pid_t = 0
    AXUIElementGetPid(win, &pid)
    return NSRunningApplication(processIdentifier: pid)
}

@MainActor
func elementAtPoint(_ p: CGPoint) -> AXUIElement? {
    var e: AXUIElement?
    AXUIElementCopyElementAtPosition(Globals.systemWide, Float(p.x), Float(p.y), &e)
    return e
}

@MainActor
func isStandardWindow(_ w: AXUIElement) -> Bool {
    if attributeString(w, kAXRoleAttribute as CFString) != "AXWindow" { return false }
    if attributeString(w, kAXSubroleAttribute as CFString) != "AXStandardWindow" { return false }
    return true
}

@MainActor
func isDialogLike(_ w: AXUIElement) -> Bool {
    let sr = attributeString(w, kAXSubroleAttribute as CFString) ?? ""
    if sr == "AXDialog" || sr == "AXSystemDialog" || sr == "AXSheet" || sr == "AXFloatingWindow" { return true }
    let title = attributeString(w, kAXTitleAttribute as CFString)?.lowercased() ?? ""
    if title.contains("preferences") || title.contains("settings") || title.contains("настройки") || title.contains("параметры") { return true }
    return false
}

@MainActor
func isSeriousWindow(_ w: AXUIElement) -> Bool {
    if !isStandardWindow(w) { return false }
    if isDialogLike(w) { return false }
    if windowHasDescendantRole(w, "AXTabGroup") { return true }
    if windowHasDocument(w) { return true }
    return false
}

@MainActor
func hideApp(for win: AXUIElement) -> Bool {
    guard let app = appOfWindow(win) else { return false }
    return app.hide()
}

@MainActor
func handleLeftMouseDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
    let loc = event.location
    if let el = elementAtPoint(loc), let closeEl = findCloseButtonAncestor(el), let win = ancestorWindow(from: closeEl) {
        if isSeriousWindow(win) {
            if hideApp(for: win) { Globals.swallowNextUp = true; return nil }
        }
    }
    return Unmanaged.passUnretained(event)
}

@MainActor
func windowHasDocument(_ w: AXUIElement) -> Bool {
    var v: CFTypeRef?
    if AXUIElementCopyAttributeValue(w, kAXDocumentAttribute as CFString, &v) != .success { return false }
    return v != nil
}

@MainActor
func windowHasDescendantRole(_ w: AXUIElement, _ role: String, maxDepth: Int = 32) -> Bool {
    var queue: [AXUIElement] = [w]
    var depth = 0
    while !queue.isEmpty && depth < maxDepth {
        let level = queue
        queue.removeAll(keepingCapacity: true)
        for e in level {
            if let r = attributeString(e, kAXRoleAttribute as CFString), r == role { return true }
            if let children = attributeArray(e, kAXChildrenAttribute as CFString) { queue.append(contentsOf: children) }
        }
        depth += 1
    }
    return false
}
