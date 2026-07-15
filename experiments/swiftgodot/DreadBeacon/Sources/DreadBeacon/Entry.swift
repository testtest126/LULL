import SwiftGodot

// GDExtension entry point. Godot dlopens the built library, calls this
// symbol (matching `entry_symbol` in DreadBeacon.gdextension), and this
// macro expands to the registration/init boilerplate shown in the SwiftGodot
// README ("Creating an Extension").
#initSwiftExtension(cdecl: "swift_entry_point", types: [DreadBeacon.self])
