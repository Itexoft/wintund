import Foundation
import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics
import Dispatch

enum Globals {
    @MainActor static var eventTap: CFMachPort?
    @MainActor static var swallowNextUp = false
    @MainActor static var swallowMouseUp = false
    @MainActor static var swallowNextMouseUp = false
    @MainActor static var systemWide: AXUIElement!
    @MainActor static var globalConfig: Config!
    @MainActor static var origTile: Float = 0
    @MainActor static var origOrient: Int32 = 0
    @MainActor static var origPin: Int32 = 0
    @MainActor static var changedPin = false
}
