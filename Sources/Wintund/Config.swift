import Foundation

struct Ini { var sections: [String: [String: String]] }

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
        if !current.isEmpty { map[current]?[k.lowercased()] = v }
    }
    return Ini(sections: map)
}

func parseBool(_ v: String?, _ def: Bool) -> Bool {
    guard let s = v?.lowercased() else { return def }
    if ["1","true","yes","on","y"].contains(s) { return true }
    if ["0","false","no","off","n"].contains(s) { return false }
    return def
}

struct Config {
    var enableCloseMinimizer: Bool
    var enableGreenZoom: Bool
}

func resolveConfigPath() -> String? {
    var it = CommandLine.arguments.makeIterator()
    _ = it.next()
    while let a = it.next() { if a == "--config", let v = it.next() { return v } }
    return nil
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
    let enableClose = parseBool(c1["enabled"], true)
    let enableGreen = parseBool(c2["enabled"], true)
    return Config(enableCloseMinimizer: enableClose, enableGreenZoom: enableGreen)
}