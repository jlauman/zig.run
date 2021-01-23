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
const std = @import("std");

pub fn main() !void {
    std.debug.print("hello, world!\n", .{});
}
