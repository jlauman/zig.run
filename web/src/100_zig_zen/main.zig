//! Zig zen
//!
//! * Communicate intent precisely.
//! * Edge cases matter.
//! * Favor reading code over writing code.
//! * Only one obvious way to do things.
//! * Runtime crashes are better than bugs.
//! * Compile errors are better than runtime crashes.
//! * Incremental improvements.
//! * Avoid local maximums.
//! * Reduce the amount one must remember.
//! * Focus on code rather than style.
//! * Resource allocation may fail; resource deallocation must succeed.
//! * Memory is a resource.
//! * Together we serve the users.
//!
//!
//! see: https://zig.run/#101_std_debug_print
//! see: https://zig.run/#102_import
//! see: https://zig.run/#103_test
//!
const std = @import("std");

/// Press the triangular button on the left to execute
/// "zig run main.zig" in the code playground.
/// Select the `main.zig` tab to display the top-level doc comments.
pub fn main() !void {
    std.debug.print("hello, world!\n", .{});
}
