import Foundation

struct Ini {
    var sections: [String: [String: String]]
}

func readIni(at path: String) -> Ini {
    guard let data = try? String(contentsOfFile: path, encoding: .utf8) else { return Ini(sections: [:]) }
    var current = ""
    var map: [String: [String: String]] = [:]
    for rawLine in data.components(separatedBy: .newlines) {
        let line = rawLine.trimmingCharacters(in: .whitespaces)
        if line.isEmpty { continue }
        if line.hasPrefix(";") || line.hasPrefix("#") { continue }
        if line.hasPrefix("[") && line.hasSuffix("]") {
            current = String(line.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
            if map[current] == nil { map[current] = [:] }
            continue
        }
        guard let eq = line.firstIndex(of: "=") else { continue }
        let k = String(line[..<eq]).trimmingCharacters(in: .whitespaces)
        let v = String(line[line.index(after: eq)...]).trimmingCharacters(in: .whitespaces)
        if !current.isEmpty {
            map[current]?[k.lowercased()] = v
        }
    }
    return Ini(sections: map)
}

func parseBool(_ v: String?) -> Bool {
    guard let s = v?.lowercased() else { return false }
    if ["1","true","yes","on","y"].contains(s) { return true }
    if ["0","false","no","off","n"].contains(s) { return false }
    return false
}

func parseDouble(_ v: String?, _ def: Double) -> Double {
    guard let s = v, let d = Double(s) else { return def }
    return d
}

func parseString(_ v: String?, _ def: String) -> String {
    guard let s = v, !s.isEmpty else { return def }
    return s
}

struct Config {
    var enableCloseMinimizer: Bool
    var enableGreenZoom: Bool
    var enableClockCleaner: Bool
    var enableFixDock: Bool
    var fixDockWidth: Double
    var fixDockPin: String
    var fixDockTolerance: Double
    var fixDockInterval: TimeInterval
}

func loadConfig(path: String?) -> Config {
    var ini = Ini(sections: [:])
    if let p = path, FileManager.default.fileExists(atPath: p) { ini = readIni(at: p) }
    else {
        let exe = CommandLine.arguments.first ?? ""
        let url = URL(fileURLWithPath: exe).standardized
        let near = url.deletingLastPathComponent().appendingPathComponent("config.ini").path
        if FileManager.default.fileExists(atPath: near) { ini = readIni(at: near) }
    }
    let c1 = ini.sections["CloseButtonMinimizer"] ?? [:]
    let c2 = ini.sections["GreenZoomDaemon"] ?? [:]
    let c3 = ini.sections["ClockDesktopDaemon"] ?? [:]
    let c4 = ini.sections["FixDock"] ?? [:]
    let enableClose = c1.isEmpty ? true : parseBool(c1["enabled"])
    let enableGreen = c2.isEmpty ? true : parseBool(c2["enabled"])
    let enableClock = c3.isEmpty ? true : parseBool(c3["enabled"])
    let enableDock = parseBool(c4["enabled"])
    let width = parseDouble(c4["width"], 0)
    let pin = parseString(c4["pin"], "ignore")
    let tol = parseDouble(c4["tolerance"], 2)
    let interval = parseDouble(c4["interval"], 0.15)
    return Config(enableCloseMinimizer: enableClose, enableGreenZoom: enableGreen, enableClockCleaner: enableClock, enableFixDock: enableDock && width > 0, fixDockWidth: width, fixDockPin: pin, fixDockTolerance: tol, fixDockInterval: interval)
}
