import Foundation
import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics

enum Globals {
    nonisolated(unsafe) static var eventTap: CFMachPort?
    nonisolated(unsafe) static var swallowNextUp = false
    nonisolated(unsafe) static var swallowMouseUp = false
    nonisolated(unsafe) static var swallowNextMouseUp = false
    nonisolated(unsafe) static var systemWide: AXUIElement!
    nonisolated(unsafe) static var globalConfig: Config!
    nonisolated(unsafe) static var origTile: Float = 0
    nonisolated(unsafe) static var origOrient: Int32 = 0
    nonisolated(unsafe) static var origPin: Int32 = 0
    nonisolated(unsafe) static var changedPin = false
}
