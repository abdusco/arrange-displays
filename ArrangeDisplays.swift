import Foundation
import CoreGraphics

let currentVersion = "dev"

enum Direction: String {
    case top
    case bottom
    case left
    case right
}

class CLIArgs {
    let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    static func parse() -> CLIArgs? {
        let args = CommandLine.arguments
        
        guard args.count > 1 else {
            print("Error: Missing argument\n")
            showHelp()
            return nil
        }
        
        let arg = args[1]
        
        // Check for help flag
        if arg == "--help" || arg == "-h" {
            showHelp()
            return nil
        }
        
        // Check for version flag
        if arg == "--version" || arg == "-v" {
            print("arrange_displays v\(currentVersion)")
            return nil
        }
        
        // Parse direction
        guard let direction = Direction(rawValue: arg) else {
            print("Error: Invalid position '\(arg)'\n")
            showHelp()
            return nil
        }
        
        return CLIArgs(direction: direction)
    }
    
    static func showHelp() {
        print("""
        arrange_displays v\(currentVersion) - Arrange external display relative to internal display
        
        USAGE:
            arrange_displays <position>
            arrange_displays --help
            arrange_displays --version
        
        POSITIONS:
            top      Place external display above internal display
            bottom   Place external display below internal display
            left     Place external display to the left of internal display
            right    Place external display to the right of internal display
        
        OPTIONS:
            --help, -h      Show this help message
            --version, -v   Show version information
        
        EXAMPLES:
            arrange_displays top
            arrange_displays right
        """)
    }
}

guard let cliArgs = CLIArgs.parse() else {
    exit(1)
}

let direction = cliArgs.direction

// 1. Get online displays
var displayCount: UInt32 = 0
CGGetOnlineDisplayList(0, nil, &displayCount)
var displays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
CGGetOnlineDisplayList(displayCount, &displays, &displayCount)

print("Found \(displayCount) displays")
for (i, display) in displays.enumerated() {
    print("Display \(i): ID=\(display), builtin=\(CGDisplayIsBuiltin(display))")
}

guard displayCount >= 2 else {
    print("Error: Need at least two displays.")
    exit(1)
}

// 2. Identify MacBook (Internal) and External
// Note: CGDisplayIsBuiltin is the reliable check here.
let mainDisplay: CGDirectDisplayID = displays.first { CGDisplayIsBuiltin($0) != 0 } ?? displays[0]
let extDisplay = displays.first { $0 != mainDisplay }!

print("Main (internal) display: \(mainDisplay)")
print("External display: \(extDisplay)")

let mainBounds = CGDisplayBounds(mainDisplay)
let extBounds = CGDisplayBounds(extDisplay)

print("Main bounds: \(mainBounds)")
print("Ext bounds: \(extBounds)")

var targetX: Int32 = 0
var targetY: Int32 = 0

switch direction {
case .top:
    targetY = -Int32(extBounds.height)
case .bottom:
    targetY = Int32(mainBounds.height)
case .left:
    targetX = -Int32(extBounds.width)
case .right:
    targetX = Int32(mainBounds.width)
}

print("Setting external display to position: (\(targetX), \(targetY))")

// 3. Apply Configuration
var configRef: CGDisplayConfigRef?
CGBeginDisplayConfiguration(&configRef)
CGConfigureDisplayOrigin(configRef, extDisplay, targetX, targetY)
// Ensure main display stays at 0,0
CGConfigureDisplayOrigin(configRef, mainDisplay, 0, 0) 
let result = CGCompleteDisplayConfiguration(configRef, .permanently)

if result == .success {
    print("Arranged external display to the \(direction.rawValue)")
} else {
    print("Failed to apply configuration: \(result)")
}
