import Foundation
import AppKit
import ApplicationServices
import CoreGraphics
import Dispatch

@_silgen_name("CoreDockGetTileSize") func CoreDockGetTileSize() -> Float
@_silgen_name("CoreDockSetTileSize") func CoreDockSetTileSize(_ tileSize: Float)
@_silgen_name("CoreDockGetRect") func CoreDockGetRect(_ outRect: UnsafeMutablePointer<CGRect>)
@_silgen_name("CoreDockGetOrientationAndPinning") func CoreDockGetOrientationAndPinning(_ outOrientation: UnsafeMutablePointer<Int32>, _ outPinning: UnsafeMutablePointer<Int32>)
@_silgen_name("CoreDockSetOrientationAndPinning") func CoreDockSetOrientationAndPinning(_ orientation: Int32, _ pinning: Int32)

let kCoreDockPinningStart: Int32 = 1
let kCoreDockPinningMiddle: Int32 = 2
let kCoreDockPinningEnd: Int32 = 3

func getDockRect() -> CGRect {
    var r = CGRect.zero
    CoreDockGetRect(&r)
    return r
}

func clamp(_ v: Float, _ lo: Float, _ hi: Float) -> Float { min(max(v, lo), hi) }

@MainActor var origTile: Float = 0
@MainActor var origOrient: Int32 = 0
@MainActor var origPin: Int32 = 0
@MainActor var changedPin = false

@MainActor func startFixDockIfNeeded() {
    guard globalConfig.enableFixDock else { return }
    origTile = CoreDockGetTileSize()
    CoreDockGetOrientationAndPinning(&origOrient, &origPin)
    if globalConfig.fixDockPin == "start" { CoreDockSetOrientationAndPinning(origOrient, kCoreDockPinningStart); changedPin = true }
    else if globalConfig.fixDockPin == "middle" { CoreDockSetOrientationAndPinning(origOrient, kCoreDockPinningMiddle); changedPin = true }
    else if globalConfig.fixDockPin == "end" { CoreDockSetOrientationAndPinning(origOrient, kCoreDockPinningEnd); changedPin = true }
    for s in [SIGINT, SIGTERM, SIGHUP, SIGQUIT] {
        signal(s, SIG_IGN)
        let src = DispatchSource.makeSignalSource(signal: s, queue: .main)
        src.setEventHandler {
            CoreDockSetTileSize(origTile)
            if changedPin { CoreDockSetOrientationAndPinning(origOrient, origPin) }
            exit(0)
        }
        src.resume()
    }
    func step() {
        let rect = getDockRect()
        if rect.width <= 1 { return }
        let curW = rect.width
        let curF = CoreDockGetTileSize()
        let err = curW - globalConfig.fixDockWidth
        if abs(err) <= globalConfig.fixDockTolerance { return }
        let ratio = Float(globalConfig.fixDockWidth / curW)
        var nextF = clamp(curF * ratio, 0.01, 1.0)
        if abs(nextF - curF) < 0.001 { nextF = curF + (err > 0 ? 0.002 : -0.002) }
        CoreDockSetTileSize(nextF)
    }
    for _ in 0..<8 { step(); usleep(60000) }
    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.schedule(deadline: .now() + globalConfig.fixDockInterval, repeating: globalConfig.fixDockInterval)
    timer.setEventHandler { step() }
    timer.resume()
}
