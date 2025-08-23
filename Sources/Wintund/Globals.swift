import Foundation
import AppKit
import ApplicationServices
import CoreGraphics
import Dispatch

@MainActor var eventTap: CFMachPort?
@MainActor var swallowNextUp = false
@MainActor var swallowMouseUp = false
@MainActor var swallowNextMouseUp = false
@MainActor var systemWide: AXUIElement!
@MainActor var globalConfig: Config!
