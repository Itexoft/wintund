import Foundation
import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics

@MainActor(unsafe) enum Globals {
    static var eventTap: CFMachPort?
    static var swallowNextUp = false
    static var swallowMouseUp = false
    static var swallowNextMouseUp = false
    static var systemWide: AXUIElement!
    static var globalConfig: Config!
    static var origTile: Float = 0
    static var origOrient: Int32 = 0
    static var origPin: Int32 = 0
    static var changedPin = false
}
