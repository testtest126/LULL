import SwiftUI

/// LULL's look: a cold, near-black device screen, bone text, one restrained red.
/// The unease is in the restraint, not the palette.
enum Theme {
    static let ink   = Color(red: 0.027, green: 0.031, blue: 0.039) // #07080a
    static let bone  = Color(red: 0.843, green: 0.835, blue: 0.816) // #d7d5d0
    static let dim   = Color(red: 0.510, green: 0.522, blue: 0.549) // #82858c
    static let faint = Color(red: 0.286, green: 0.298, blue: 0.325) // #494c53
    static let red   = Color(red: 0.733, green: 0.231, blue: 0.231) // #bb3b3b

    static let label = Font.system(.caption2, design: .monospaced)
    static let body  = Font.system(.body)
    static let title = Font.system(size: 44, weight: .heavy)
}
