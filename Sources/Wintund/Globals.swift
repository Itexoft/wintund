import Foundation
import AppKit
import ApplicationServices
import CoreGraphics
import Dispatch

var eventTap: CFMachPort?
var swallowNextUp = false
var swallowMouseUp = false
var swallowNextMouseUp = false
let systemWide = AXUIElementCreateSystemWide()
var globalConfig = loadConfig(path: {
    var p: String?
    var it = CommandLine.arguments.makeIterator()
    _ = it.next()
    while let a = it.next() {
        if a == "--config", let v = it.next() { p = v; break }
    }
    return p
}())
