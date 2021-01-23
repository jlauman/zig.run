//! std.debug.print
//!
//! The std.debug.print function may be used for "printf"
//! style debugging. For printing to stdout and/or stderr 
//! see the std.io.getStdOut().writer() example.
//!
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("hello, {}!\n", .{"world"});
}
