//! std.debug.print
//!
//! The std.debug.print function may be used for "printf"
//! style debugging. For printing to stdout and/or stderr 
//! see the std.io.getStdOut() example.
//!
//! see: https://ziglang.org/documentation/0.7.1/#toc-Hello-World
//! see: https://ziglang.org/documentation/0.7.1/#Comments
//! see: https://github.com/ziglang/zig/blob/0.7.1/lib/std/debug.zig#L61
//! see: https://zig.run/#301_std_io_getstdout
//!
const std = @import("std");
// const print = std.debug.print;

/// Press the triangular button on the left to execute
/// `zig run main.zig` in the code playground.
/// Select the `main.zig` tab to display the top-level doc comments.
pub fn main() !void {
    std.debug.print("hello, {}!\n", .{"world"});
    // Uncomment the next line and run to see a zig error.
    // print("this runs in the {}.\n", .{"playground"});
}
