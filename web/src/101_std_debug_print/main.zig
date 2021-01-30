//! std.debug.print
//!
//! The std.debug.print function may be used for "printf"
//! style debugging. For printing to stdout and/or stderr 
//! see the std.io.getStdOut().writer() example.
//!
//! see: https://github.com/ziglang/zig/blob/0.7.1/lib/std/debug.zig#L61 
//! see: https://zig.run/#105_std_io_getstdout
//!
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("hello, {}!\n", .{"world"});
}
