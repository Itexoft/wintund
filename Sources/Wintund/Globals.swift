import Foundation
import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics
import Dispatch

@MainActor
enum Globals {
    static var eventTap: CFMachPort?
    static var swallowNextUp = false
    static var swallowMouseUp = false
    static var swallowNextMouseUp = false
    static let systemWide = AXUIElementCreateSystemWide()
    static let globalConfig: Config = loadConfig(path: resolveConfigPath())
    static var origTile: Float = 0
    static var origOrient: Int32 = 0
    static var origPin: Int32 = 0
    static var changedPin = false
}
