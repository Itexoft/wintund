@preconcurrency import ApplicationServices

@MainActor
enum Globals {
    static var eventTap: CFMachPort?
    static var swallowNextUp = false
    static var swallowMouseUp = false
    static var swallowPlainUp = false
    static let systemWide = AXUIElementCreateSystemWide()
    static let globalConfig: Config = loadConfig(path: resolveConfigPath())
}