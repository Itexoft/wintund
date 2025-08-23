import Foundation
import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics
import Dispatch

@_silgen_name("CoreDockGetTileSize") func CoreDockGetTileSize() -> Float
@_silgen_name("CoreDockSetTileSize") func CoreDockSetTileSize(_ tileSize: Float)
@_silgen_name("CoreDockGetRect") func CoreDockGetRect(_ outRect: UnsafeMutablePointer<CGRect>)
@_silgen_name("CoreDockGetOrientationAndPinning") func CoreDockGetOrientationAndPinning(_ outOrientation: UnsafeMutablePointer<Int32>, _ outPinning: UnsafeMutablePointer<Int32>)
@_silgen_name("CoreDockSetOrientationAndPinning") func CoreDockSetOrientationAndPinning(_ orientation: Int32, _ pinning: Int32)

enum DockConst {
    static let pinningStart: Int32 = 1
    static let pinningMiddle: Int32 = 2
    static let pinningEnd: Int32 = 3
}

func getDockRect() -> CGRect {
    var r = CGRect.zero
    CoreDockGetRect(&r)
    return r
}

func clamp(_ v: Float, _ lo: Float, _ hi: Float) -> Float { min(max(v, lo), hi) }

@MainActor func startFixDockIfNeeded() {
    guard Globals.globalConfig.enableFixDock else { return }
    Globals.origTile = CoreDockGetTileSize()
    CoreDockGetOrientationAndPinning(&Globals.origOrient, &Globals.origPin)
    if Globals.globalConfig.fixDockPin == "start" { CoreDockSetOrientationAndPinning(Globals.origOrient, DockConst.pinningStart); Globals.changedPin = true }
    else if Globals.globalConfig.fixDockPin == "middle" { CoreDockSetOrientationAndPinning(Globals.origOrient, DockConst.pinningMiddle); Globals.changedPin = true }
    else if Globals.globalConfig.fixDockPin == "end" { CoreDockSetOrientationAndPinning(Globals.origOrient, DockConst.pinningEnd); Globals.changedPin = true }
    for s in [SIGINT, SIGTERM, SIGHUP, SIGQUIT] {
        signal(s, SIG_IGN)
        let src = DispatchSource.makeSignalSource(signal: s, queue: .main)
        src.setEventHandler {
            CoreDockSetTileSize(Globals.origTile)
            if Globals.changedPin { CoreDockSetOrientationAndPinning(Globals.origOrient, Globals.origPin) }
            exit(0)
        }
        src.resume()
    }
    func step() {
        let rect = getDockRect()
        if rect.width <= 1 { return }
        let curW = rect.width
        let curF = CoreDockGetTileSize()
        let err = curW - Globals.globalConfig.fixDockWidth
        if abs(err) <= Globals.globalConfig.fixDockTolerance { return }
        let ratio = Float(Globals.globalConfig.fixDockWidth / curW)
        var nextF = clamp(curF * ratio, 0.01, 1.0)
        if abs(nextF - curF) < 0.001 { nextF = curF + (err > 0 ? 0.002 : -0.002) }
        CoreDockSetTileSize(nextF)
    }
    for _ in 0..<8 { step(); usleep(60000) }
    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.schedule(deadline: .now() + Globals.globalConfig.fixDockInterval, repeating: Globals.globalConfig.fixDockInterval)
    timer.setEventHandler { step() }
    timer.resume()
}
